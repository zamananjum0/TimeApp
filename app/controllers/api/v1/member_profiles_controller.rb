class Api::V1::MemberProfilesController < ApplicationController

  def get_following_requests
    # params = {
    #     "auth_token": "24d13da419b8ce1138360e22c1f548e64f4b5379b2f9c4d2c6450f4c81f3cb6085d4a6f68f8471861144d87bc163205f01abc3559cd84be8f7f658bb1409151e0953e12c4239b587c43b4f638862ad740336e28846579cc70dfc17d7427fff74a3e12f84",
    #     "page": 1,
    #     "per_page": 10
    # }

    user_session = UserSession.find_by_auth_token(params[:auth_token])
    if user_session.present?
      resp_data  =  MemberFollowing.get_following_requests(params, user_session.user)
      render json: resp_data
    else
      resp = {resp_data: {}, status: 0, message: 'error'}
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
      resp = {resp_data: {}, status: 0, message: 'error'}
      return render json: resp
    end
  end

  def get_followers
    # params = {
    #     "auth_token": "24d13da419b8ce1138360e22c1f548e64f4b5379b2f9c4d2c6450f4c81f3cb6085d4a6f68f8471861144d87bc163205f01abc3559cd84be8f7f658bb1409151e0953e12c4239b587c43b4f638862ad740336e28846579cc70dfc17d7427fff74a3e12f84",
    #     "page": 1,
    #     "per_page": 10,
    #     "member_profile":
    #       {
    #         "id": 1,
    #         "search_key": ''
    #       }
    # }

    user_session = UserSession.find_by_auth_token(params[:auth_token])
    if user_session.present?
      resp_data  =  MemberFollowing.get_followers(params, user_session.user)
      render json: resp_data
    else
      resp = {resp_data: {}, status: 0, message: 'error'}
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
      resp = {resp_data: {}, status: 0, message: 'error'}
      return render json: resp
    end
  end

  def get_following_members
    # params = {
    #     "auth_token": "24d13da419b8ce1138360e22c1f548e64f4b5379b2f9c4d2c6450f4c81f3cb6085d4a6f68f8471861144d87bc163205f01abc3559cd84be8f7f658bb1409151e0953e12c4239b587c43b4f638862ad740336e28846579cc70dfc17d7427fff74a3e12f84",
    #     "page": 1,
    #     "per_page": 10,
    #     "member_profile":
    #       {
    #         "id": '1',
    #         "search_key": ''
    #       }
    # }

    user_session = UserSession.find_by_auth_token(params[:auth_token])
    if user_session.present?
      resp_data  =  MemberFollowing.get_following_members(params, user_session.user)
      render json: resp_data
    else
      resp = {resp_data: {}, status: 0, message: 'error'}
      return render json: resp
    end
  end

  def get_profile
    # params = {
    #     "auth_token": "24d13da419b8ce1138360e22c1f548e64f4b5379b2f9c4d2c6450f4c81f3cb6085d4a6f68f8471861144d87bc163205f01abc3559cd84be8f7f658bb1409151e0953e12c4239b587c43b4f638862ad740336e28846579cc70dfc17d7427fff74a3e12f84",
    #     "member_profile_id": 1
    # }

    user_session = UserSession.find_by_auth_token(params[:auth_token])
    if user_session.present?
      resp_data  =  MemberProfile.get_profile(params, user_session.user)
      render json: resp_data
    else
      resp = {resp_data: {}, status: 0, message: 'error'}
      return render json: resp
    end
  end

  def account_update
    # params = {
    #     "auth_token": "24d13da419b8ce1138360e22c1f548e64f4b5379b2f9c4d2c6450f4c81f3cb6085d4a6f68f8471861144d87bc163205f01abc3559cd84be8f7f658bb1409151e0953e12c4239b587c43b4f638862ad740336e28846579cc70dfc17d7427fff74a3e12f84",
    #     "member_profile":
    #       {
    #           "account_type": "standard"
    #       }
    # }

    user_session = UserSession.find_by_auth_token(params[:auth_token])
    if user_session.present?
      resp_data  =  MemberProfile.account_update(params, user_session.user)
      render json: resp_data
    else
      resp = {resp_data: {}, status: 0, message: 'error'}
      return render json: resp
    end
  end

  def profile_timeline
    # params = {
    #     "auth_token": "24d13da419b8ce1138360e22c1f548e64f4b5379b2f9c4d2c6450f4c81f3cb6085d4a6f68f8471861144d87bc163205f01abc3559cd84be8f7f658bb1409151e0953e12c4239b587c43b4f638862ad740336e28846579cc70dfc17d7427fff74a3e12f84",
    #     page: 1,
    #     per_page: 10,
    #     member_profile_id: 1
    # }

    user_session = UserSession.find_by_auth_token(params[:auth_token])
    if user_session.present?
      resp_data  =  MemberProfile.profile_timeline(params, user_session.user)
      render json: resp_data
    else
      resp = {resp_data: {}, status: 0, message: 'error'}
      return render json: resp
    end
  end



end






