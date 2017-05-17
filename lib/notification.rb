module Notification

  def self.send_event_notification(user, alert, screen, is_notification_save, screen_data = {})
    begin
      badge = 1
      if is_notification_save
        push_notification             = PushNotification.new
        push_notification.user_id     = user.id
        push_notification.alert       = alert
        push_notification.badge       = badge
        push_notification.screen      = screen
        push_notification.screen_data = screen_data
        push_notification.save
      end
      if user.present? && user.device_type.present? && user.device_token.present?
        if user.device_type == AppConstants::DEVICE_IOS
          data = {
              screen:     screen,
              screen_data: screen_data,
              user:{
                  id: 1,
                  username: user.username,
                  profile: {
                      id: user.profile_id,
                      photo: user.profile.photo
                  }
              }
          }

          app = RailsPushNotifications::APNSApp.first
          app.notifications.create(
              destinations: [user.device_token],
              data: {
                  aps: {
                      alert: alert,
                      badge: 1,
                      sound: 'default',
                      other: data
                  }
              }
          )
          notification = app.push_notifications
        end
      end
    rescue => e
      puts e.inspect
    end
  end
end