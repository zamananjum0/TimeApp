class Api::V1::RegistrationsController < ApplicationController
  
  def sign_up
    # params = {
    #     member_profile: {
    #        "photo": "URL",
    #         user_attributes: {
    #             email: "test1@gmail.com",
    #             username: 'Test'
    #             password: "test123456",
    #             password_confirmation: "test123456"
    #         }
    #     }
    # }
    resp_data = MemberProfile.sign_up(params)
    render json: resp_data
  end
  
  def sing_up_social_media
    resp_data = MemberProfile.social_media_sign_up(params)
    render json: resp_data
  end

  def forgot_password
    resp_data = User.forgot_password(params)
    render json: resp_data
  end

end
