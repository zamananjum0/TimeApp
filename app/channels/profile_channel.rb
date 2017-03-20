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

  def search_member(data)
    response = MemberFollowing.search_member(data, current_user)
    ProfileJob.perform_later response, current_user.id
  end

  def follow_member(data)
    response, is_accepted = MemberFollowing.follow_member(data, current_user)
    ProfileJob.perform_later response, current_user.id
    if is_accepted
      response = Post.newly_created_posts(current_user)
      PostJob.perform_later response, current_user.id
    end
  end

  def unfollow_member(data)
    response = MemberFollowing.unfollow_member(data, current_user)
    ProfileJob.perform_later response, current_user.id
  end

  def update(data)
    response = MemberProfile.update(data, current_user)
    ProfileJob.perform_later response, current_user.id
  end

  def other_member_profile(data)
    response = MemberProfile.other_member_profile(data, current_user)
    ProfileJob.perform_later response, current_user.id
  end

  def create_message(data)
    response = Message.create_message(data, current_user)
    ProfileJob.perform_later response, current_user.id
  end

  def show_inbox(data)
    response = Message.show_inbox(data, current_user)
    ProfileJob.perform_later response, current_user.id
  end

  def event_create(data)
    response = Event.event_create(data, current_user)
    ProfileJob.perform_later response, current_user.id
  end

  def attend_event(data)
    response = AttendedEvent.attend_event(data, current_user)
    ProfileJob.perform_later response, current_user.id
  end

  def show_event(data)
    response = Event.show_event(data, current_user)
    ProfileJob.perform_later response, current_user.id
  end

  def event_list(data)
    response = Event.event_list(data, current_user)
    ProfileJob.perform_later response, current_user.id
  end

  def event_search(data)
    response = Event.event_search(data, current_user)
    ProfileJob.perform_later response, current_user.id
  end









  # def group_create(data)
  #   response = MemberGroup.group_create(data, current_user)
  #   ProfileJob.perform_later response, current_user.id
  # end
  #
  # def group_show(data)
  #   response = MemberGroup.group_show(data, current_user)
  #   ProfileJob.perform_later response, current_user.id
  # end
  #
  # def group_destroy(data)
  #   response = MemberGroup.group_destroy(data, current_user)
  #   ProfileJob.perform_later response, current_user.id
  # end
  #
  # def group_update(data)
  #   response = MemberGroup.group_update(data, current_user)
  #   ProfileJob.perform_later response, current_user.id
  # end
  #
  # def add_member_to_group(data)
  #   response = MemberGroup.add_member_to_group(data, current_user)
  #   ProfileJob.perform_later response, current_user.id
  # end
  #
  # def group_index(data)
  #   response = MemberGroup.group_index(data, current_user)
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
