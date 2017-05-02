task :define_ranking => :environment do
  events = Event.where("DATE_PART('hour', start_date) = ? AND DATE(start_date) = DATE(?)", DateTime.now.hour, Date.today)
  users  = User.where(is_deleted: false, profile_type: AppConstants::MEMBER)
  events&.each do |event|
    users&.each do |user|
      alert = AppConstants::NEW_EVENT
      screen_data = {event_id: event.id, start_date: event.start_date, end_date: event.end_date, description: event.description}.as_json
      Notification.send_event_notification(user, alert, AppConstants::EVENT, true, screen_data)
    end
  end
end
