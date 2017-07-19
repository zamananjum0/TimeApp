task :define_ranking => :environment do
  # events = Event.where("DATE_PART('hour', end_date) = ? AND DATE(end_date) = DATE(?)", DateTime.now.hour, Date.today)
  events = Event.all
  
  events && events.each do |event|
    tag_ids  = event.hashtags.pluck(:id)
    # post_ids = MediaTag.where(media_type: AppConstants::POST, hashtag_id: tag_ids).pluck(:media_id)
    
    # posts    = Post.where('created_at >= ? AND created_at <= ? AND id IN (?)', event.start_date, event.end_date, post_ids)
    # posts    = Post.where('id IN (?)', post_ids)
    
    post_ids = posts.pluck(:id)
    post = Post.joins(:likes).select("posts.*, COUNT('likes.id') likes_count").where(likes: {likable_type: 'Post', is_like: true}, event_id: event.id).group('posts.id').order('likes_count DESC').try(:first)
    if post.present?
      event.post_id = post.id
      event.member_profile_id = post.member_profile_id
      event.save!
      # Increase Post limit of profile
      profile = post.member_profile
      profile.remaining_posts_count  = profile.remaining_posts_count + AppConstants::POST_COUNT
      profile.save!
    end
  end
end
