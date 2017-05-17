class Api::V1::MemberFollowingsController < ApplicationController
  
  def search_member
     # params ={
     #   auth_token: UserSession.last.auth_token,
     #   "per_page": 10,
     #   "page": 1,
     #   "search_key": ""
     # }
    user_session = UserSession.find_by_auth_token(params[:auth_token])
    if user_session.present?
      resp_data = MemberFollowing.search_member(params, user_session.user)
      render json: resp_data
    else
      resp_data = {resp_status: 0, message: 'Invalid Token', error: '', data: {}}
      return render json: resp_data
    end
  end

  def follow_member
    # params ={
    #   auth_token: "",
    #   "following_profile_id": "101d14d2-68c4-497d-b367-33c69d98165d"
    # }
    user_session = UserSession.find_by_auth_token(params[:auth_token])
    if user_session.present?
      resp_data, is_accepted = MemberFollowing.follow_member(params, user_session.user)
      render json: resp_data
    else
      resp_data = {resp_status: 0, message: 'Invalid Token', error: '', data: {}}
      return render json: resp_data
    end
  end

  def unfollow_member
    # params ={
    #   auth_token: "",
    #   "following_profile_id": "101d14d2-68c4-497d-b367-33c69d98165d"
    # }
    user_session = UserSession.find_by_auth_token(params[:auth_token])
    if user_session.present?
      resp_data, is_accepted = MemberFollowing.unfollow_member(params, user_session.user)
      render json: resp_data
    else
      resp_data = {resp_status: 0, message: 'Invalid Token', error: '', data: {}}
      return render json: resp_data
    end
  end
  
end
