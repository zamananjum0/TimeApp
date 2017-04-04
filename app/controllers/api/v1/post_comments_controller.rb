class Api::V1::PostCommentsController < ApplicationController
  
  def index
    # params ={
    #   auth_token: UserSession.last.auth_token,
    #   "per_page": 10,
    #   "page": 1,
    #   "min_comment_date": "2017-03-23T04:38:02.751Z",
    #   "post":{
    #       "id": "03f6c639-cb0d-4c16-aecb-e44c3757fdfb"
    #   }
    # }
    user_session = UserSession.find_by_auth_token(params[:auth_token])
    if user_session.present?
      resp_data = Comment.comments_list(params, user_session.user)
      render json: resp_data
    else
      resp_data = {resp_status: 0, message: 'Invalid Token', error: '', data: {}}
      return render json: resp_data
    end
  end
end
