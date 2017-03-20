class Api::V1::UserSessionsController < ApplicationController

  def login
    # params = {
    #     "user":{
    #         "email":"test1@gmail.com",
    #         "password":"test123456"
    #     },
    #     "user_session": {
    #         "device_uuid": "vBD-y53ED85-FB4",
    #         "device_type": "ios",
    #         "device_token": "637vvs6-6-6-6-6-6-7"
    #     }
    # }
    resp_data = User.sign_in(params)
    render json: resp_data
  end


  def logout

    # params = {
    #     "auth_token": "24d13da419b8ce1138360e22c1f548e64f4b5379b2f9c4d2c6450f4c81f3cb6085d4a6f68f8471861144d87bc163205f01abc3559cd84be8f7f658bb1409151e0953e12c4239b587c43b4f638862ad740336e28846579cc70dfc17d7427fff74a3e12f84"
    # }

    user_session = UserSession.find_by_auth_token(params[:auth_token])
    if user_session.present?
      resp_data = User.log_out(params, user_session)
      render json: resp_data
    else
      resp_data = {resp_status: 0, message: 'Invalid Token00', error: '', data: {}}
      return render json: resp_data
    end
  end


  private

  def load_user_using_perishable_token
    @user = User.find_by_perishable_token(params[:token])
  end

end
