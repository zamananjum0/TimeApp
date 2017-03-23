class ProfileJob < ApplicationJob
  queue_as :default

  def perform(response, user_ids)
    users = []
    if user_ids.is_a? String
      users << "profile_channel_#{user_ids}"
    else
      user_ids && user_ids.each do |user_id|
        users << "profile_channel_#{user_id}"
      end
    end
    ActionCable.server.broadcast_multiple users, response
  end
end
