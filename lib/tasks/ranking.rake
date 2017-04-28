task :define_ranking => :environment do
  events  = Event.where('end_date > ? AND end_date <= ?', DateTime.now.beginning_of_day.to_s, DateTime.now.to_s).order('end_date DESC')
  events && events.each do |event|
    tag_ids  = event.hashtags.pluck(:id)
    post_ids = MediaTag.where(media_type: AppConstants::POST, hashtag_id: tag_ids).pluck(:media_id)
    posts    = Post.where('created_at >= ? AND created_at <= ? AND id IN (?)', event.start_date, event.end_date, post_ids)
    post_ids = posts.pluck(:id)
    post = Post.joins(:likes).select("posts.*, COUNT('likes.id') likes_count").where(likes: {likable_type: 'Post', is_like: true}, id: post_ids).group('posts.id').order('likes_count DESC').try(:first)
    
    if post.present?
      event.post_id = post.id
      event.member_profile_id = post.member_profile_id
      event.save!
      # Increase Post limit of profile
      profile = post.member_profile
      profile.remaining_posts_count  = profile.remaining_posts_count + 10
      profile.save!
    end
  end
end
