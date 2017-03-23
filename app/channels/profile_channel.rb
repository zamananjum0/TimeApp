class ProfileChannel < ApplicationCable::Channel

  def subscribed
    if current_user.present?
      stream_from "profile_channel_#{current_user.id}"
    else
      current_user = find_verified_user
      stream_from "profile_channel_#{current_user.id}"
    end
  end

  def unsubscribed
    stop_all_streams
  end
  
  # def follow_member(data)
  #   response, is_accepted = MemberFollowing.follow_member(data, current_user)
  #   ProfileJob.perform_later response, current_user.id
  #   if is_accepted
  #     response = Post.newly_created_posts(current_user)
  #     PostJob.perform_later response, current_user.id
  #   end
  # end

  # def unfollow_member(data)
  #   response = MemberFollowing.unfollow_member(data, current_user)
  #   ProfileJob.perform_later response, current_user.id
  # end

  protected
  def find_verified_user
    user_session = UserSession.find_by_auth_token(params[:auth_token])

    if user_session.present?
      user_session.user
    else
      reject_unauthorized_connection
    end
  end
end
