task :send_notification => :environment do
  # puts "XXX start XXX"*20
  # puts DateTime.now
  # events = Event.where("DATE_PART('hour', start_date) = ? AND DATE(start_date) = DATE(?)", DateTime.now.hour, Date.today)
  # users  = User.where(is_deleted: false, profile_type: AppConstants::MEMBER)
  # events&.each do |event|
  #   alert = AppConstants::NEW_EVENT
  #   screen_data = {event_id: event.id, start_date: event.start_date, end_date: event.end_date, description: event.description}.as_json
  #   push_notification             = PushNotification.new
  #   push_notification.alert       = alert
  #   push_notification.badge       = 1
  #   push_notification.screen      = AppConstants::EVENT
  #   push_notification.screen_data = screen_data
  #   push_notification.save!
  #
  #   users&.each do |user|
  #     Notification.send_event_notification(user, alert, AppConstants::EVENT, false, screen_data)
  #   end
  # end
end
