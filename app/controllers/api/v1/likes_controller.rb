class Api::V1::LikesController < Api::V1::ApiProtectedController
  
  # Call from web
  def index
    # params ={
    #   auth_token: "d3bb2b7b15943a3b013dbc3095d652e9c364cb0b75f53fa4dca5ccdcb2596a8af9d398d5d6bb5b58f4650f95bf1742a113c14e7624fb8170f604521a19170c96f23cdff5668e5b85c7177066d0aad445ad6776c103ab595fde7c21d9488b8681f3cbe9df",
    #   "per_page": 10,
    #   "page": 1,
    #   "post_id": "23232332323"
    # }
    user_session = UserSession.find_by_auth_token(params[:auth_token])
    if user_session.present?
      resp_data = Like.post_likes_list(params, user_session.user)
      render json: resp_data
    else
      resp_data = {resp_status: 0, message: 'Invalid Token', error: '', data: {}}
      return render json: resp_data
    end
  end

end
