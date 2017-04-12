task :define_ranking => :environment do
  # events  = Event.where('end_date > ? AND end_date < ?', DateTime.now.beginning_of_day, DateTime.now).order('end_date DESC')
  events  = Event.where('end_date < ?', DateTime.now).order('end_date DESC')
  events && events.each do |event|
    post =  Post.joins(:likes).select("posts.*, COUNT('likes.id') likes_count").where(likes: {likable_type: 'Post', is_like: true}, event_id: event.id).group('posts.id').order('likes_count DESC').try(:first)
    event.post_id = post.id
    event.save!
  end
end