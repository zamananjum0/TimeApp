class Api::V1::MessagesController < ApplicationController

  def show_inbox
    # params = {
    #     auth_token: "24d13da419b8ce1138360e22c1f548e64f4b5379b2f9c4d2c6450f4c81f3cb6085d4a6f68f8471861144d87bc163205f01abc3559cd84be8f7f658bb1409151e0953e12c4239b587c43b4f638862ad740336e28846579cc70dfc17d7427fff74a3e12f84",
    #     page: 1,
    #     per_page: 10,
    #     member_profile_id: 5
    # }
    user_session = UserSession.last
    if user_session.present?
      resp_data =  Message.show_inbox(params, user_session.user)
      return render json: resp_data
    else
      resp_data = 'Invalid Token'
      return render json: resp_data
    end
  end

end
