class Api::V1::CommentsController < Api::V1::ApiProtectedController
  
    def index
      # params ={
      #   auth_token: UserSession.last.auth_token,
      #   "per_page": 10,
      #   "page": 1,
      #   "post":{
      #       "id": Post.first.id
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
