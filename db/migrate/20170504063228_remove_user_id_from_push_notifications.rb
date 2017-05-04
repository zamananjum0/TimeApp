class RemoveUserIdFromPushNotifications < ActiveRecord::Migration[5.0]
  def change
    remove_column :push_notifications, :user_id
  end
end
