class Api::V1::PostCommentsController < ApplicationController
  
  def index
    # params ={
    #   auth_token: "cf18e0b778e02243cc3e3d4b01add1012a1d8862dfb9f7f5e51302b275c2b30a7dfc792ee6d362036bf1076d151c96896d4e85d2f48d5570769fd3a4fd2afa5c89c2b65cffe2cc5d93dc8f2e5841be2fcb1a136d68153b9e9a9990feca5d10d55026807e",
    #   "per_page": 10,
    #   "page": 1,
    #   "post_id": "03f6c639-cb0d-4c16-aecb-e44c3757fdfb"
    # }
    user_session = UserSession.find_by_auth_token(params[:auth_token])
    if user_session.present?
      resp_data = PostComment.post_comments_list(params, user_session.user)
      render json: resp_data
    else
      resp_data = {resp_status: 0, message: 'Invalid Token', error: '', data: {}}
      return render json: resp_data
    end
  end
end
