class Api::V1::MemberProfilesController < ApplicationController

  def get_following_requests
    # params = {
    #     "auth_token": "24d13da419b8ce1138360e22c1f548e64f4b5379b2f9c4d2c6450f4c81f3cb6085d4a6f68f8471861144d87bc163205f01abc3559cd84be8f7f658bb1409151e0953e12c4239b587c43b4f638862ad740336e28846579cc70dfc17d7427fff74a3e12f84",
    #     "page": 1,
    #     "per_page": 10
    # }

    user_session = UserSession.find_by_auth_token(params[:auth_token])
    if user_session.present?
      resp_data  =  MemberFollowing.get_following_pending_requests(params, user_session.user)
      render json: resp_data
    else
      resp = {resp_status: 0, message: 'Invalid Token', error: '', data: {}}
      return render json: resp
    end
  end

  def get_followers_requests
    # params = {
    #     "auth_token": "24d13da419b8ce1138360e22c1f548e64f4b5379b2f9c4d2c6450f4c81f3cb6085d4a6f68f8471861144d87bc163205f01abc3559cd84be8f7f658bb1409151e0953e12c4239b587c43b4f638862ad740336e28846579cc70dfc17d7427fff74a3e12f84",
    #     "page": 1,
    #     "per_page": 10
    # }

    user_session = UserSession.find_by_auth_token(params[:auth_token])
    if user_session.present?
      resp_data  =  MemberFollowing.get_followers_pending_requests(params, user_session.user)
      render json: resp_data
    else
      resp = {resp_status: 0, message: 'Invalid Token', error: '', data: {}}
      return render json: resp
    end
  end

  def get_followers
    # params = {
    #     "auth_token": UserSession.last.auth_token,
    #     "page": 1,
    #     "per_page": 10,
    #     "member_profile":
    #       {
    #         "id": "58315f65-68d6-433a-b5a2-9f9dbc489480",
    #         "search_key": ""
    #       }
    # }

    user_session = UserSession.find_by_auth_token(params[:auth_token])
    if user_session.present?
      resp_data  =  MemberFollowing.get_followers(params, user_session.user)
      render json: resp_data
    else
      resp = {resp_status: 0, message: 'Invalid Token', error: '', data: {}}
      return render json: resp
    end
  end

  def accepted_rejected_follower
    # params = {
    #     "auth_token": "24d13da419b8ce1138360e22c1f548e64f4b5379b2f9c4d2c6450f4c81f3cb6085d4a6f68f8471861144d87bc163205f01abc3559cd84be8f7f658bb1409151e0953e12c4239b587c43b4f638862ad740336e28846579cc70dfc17d7427fff74a3e12f84",
    #     "member_following":
    #       {
    #         "id": 1,
    #         "following_status": "accepted"
    #       }
    # }

    user_session = UserSession.find_by_auth_token(params[:auth_token])
    if user_session.present?
      resp_data  =  MemberFollowing.accept_reject_follower(params, user_session.user)
      render json: resp_data
    else
      resp = {resp_status: 0, message: 'Invalid Token', error: '', data: {}}
      return render json: resp
    end
  end

  def get_followings
    # params = {
    #     "auth_token": UserSession.last.auth_token,
    #     "page": 1,
    #     "per_page": 10,
    #     "member_profile":
    #       {
    #         "id": "58315f65-68d6-433a-b5a2-9f9dbc489480",
    #         "search_key": ""
    #       }
    # }

    user_session = UserSession.find_by_auth_token(params[:auth_token])
    if user_session.present?
      resp_data  =  MemberFollowing.get_following_members(params, user_session.user)
      render json: resp_data
    else
      resp = {resp_status: 0, message: 'Invalid Token', error: '', data: {}}
      return render json: resp
    end
  end

  def get_profile
    # params = {
    #     "auth_token": "ed9baa3732884d017eaebf5d737e37d9b9fa62faa5d12cd609ca2ac4640195b44d830767b5d5fa3ef183d4b2232d672946b7fa5b03a45608f435bc95712c9c0e5efaf24b73a2f16945d2f879f0ccc40fe3f99be70fd8ef199d342fdf708fe015a01a5f59",
    #     "member_profile_id": 1
    # }

    user_session = UserSession.find_by_auth_token(params[:auth_token])
    if user_session.present?
      resp_data  =  MemberProfile.get_profile(params, user_session.user)
      render json: resp_data
    else
      resp = {resp_status: 0, message: 'Invalid Token', error: '', data: {}}
      return render json: resp
    end
  end
  
  def profile_timeline
    # params = {
    #     "auth_token": "cf18e0b778e02243cc3e3d4b01add1012a1d8862dfb9f7f5e51302b275c2b30a7dfc792ee6d362036bf1076d151c96896d4e85d2f48d5570769fd3a4fd2afa5c89c2b65cffe2cc5d93dc8f2e5841be2fcb1a136d68153b9e9a9990feca5d10d55026807e",
    #     "page": 1,
    #     "per_page": 10,
    #     "member_profile_id": "23232-2323-2323"
    # }
    user_session = UserSession.find_by_auth_token(params[:auth_token])
    if user_session.present?
      resp_data  =  MemberProfile.profile_timeline(params, user_session.user)
      render json: resp_data
    else
      resp = {resp_status: 0, message: 'Invalid Token', error: '', data: {}}
      return render json: resp
    end
  end

  def profile_update
    # params = {
    #     "auth_token": "1111111",
    #     "member_profile":{
    #         "photo": "URL",
    #         "available_start_time": "2016-06-2 10:48:49",
    #         "available_end_time": "2016-06-12 10:48:49"
    #     },
    #     "user":{
    #         "username":"Paracha",
    #         "id":"1"
    #     }
    # }
  
    user_session = UserSession.find_by_auth_token(params[:auth_token])
    if user_session.present?
      resp_data  =  MemberProfile.update(params, user_session.user)
      render json: resp_data
    else
      resp = {resp_status: 0, message: 'Invalid Token', error: '', data: {}}
      return render json: resp
    end
  end
  
end






