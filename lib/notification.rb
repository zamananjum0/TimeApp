module Notification

  def self.send_event_notification(user, alert, screen, screen_data = {})
    begin
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