class Api::V1::EventsController < Api::V1::ApiProtectedController
  
  # call from app and web
  def index
    # params = {
    #     "auth_token": UserSession.last.auth_token,
    #     "min_event_date": "2017-04-13T11:33:59.881Z",
    #     "search_key": ""
    # }
    user_session = UserSession.find_by_auth_token(params[:auth_token])
    if user_session.present?
      resp_data  =  Event.event_list(params, user_session.user)
      render json: resp_data
    else
      resp = {resp_data: {}, resp_status: 0, resp_message: 'error'}
      return render json: resp
    end
  end
  
  # call from app
  def show
    user_session = UserSession.find_by_auth_token(params[:auth_token])
    if user_session.present?
      resp_data  =   Event.show_event(params, user_session.user)
      render json: resp_data
    else
      resp = {resp_data: {}, resp_status: 0, resp_message: 'error'}
      return render json: resp
    end
  end
 
  # call from web
  def event_posts
    current_user = User.find_by_id(params[:current_user_id])
    profile      = current_user.profile
    event        =  Event.find_by_id(params[:event_id])
    posts        =  event.posts
    posts        =  posts.page(params[:page].to_i).per_page(params[:per_page].to_i)
    paging_data  =  get_paging_data(params[:page], params[:per_page], posts)
    resp_data    =  Post.posts_array_response(posts, profile)
    resp_status  = 1
    resp_message = 'Success'
    resp_errors  = ''
    common_api_response(resp_data, resp_status, resp_message, resp_errors, paging_data)
  end

  # Call from web
  def block_event
      event = Event.find_by_id(params[:event_id])
      if event.present?
        event.is_deleted = params[:is_block]
        event.save!
        resp_data    =  {}
        resp_status  = 1
        resp_message = 'Success'
        resp_errors  = ''
      else
        resp_data    =  {}
        resp_status  = 0
        resp_message = 'error'
        resp_errors  = 'Event not found.'
      end
      common_api_response(resp_data, resp_status, resp_message, resp_errors)
  end
  
  # Call from web
  def create
    event = Event.new(event_params)
    
    if event.save
      resp = {resp_data: {}, resp_status: 1, resp_message: 'success'}
      return render json: resp
    else
      resp = {resp_data: {}, resp_status: 0, resp_message: 'error'}
      return render json: resp
    end
  end
  
  # Call from web
  def update
    event = Event.find_by_id(params[:id])
    if event.update_attributes(event_params)
      resp = {resp_data: {}, resp_status: 1, resp_message: 'success'}
      return render json: resp
    else
      resp = {resp_data: {}, resp_status: 0, resp_message: 'error'}
      return render json: resp
    end
  end

  # Call from app
  def global_winners
    # params = {
    #     "auth_token": UserSession.last.auth_token,
    #     # "max_event_date": end_date
    # }
    user_session = UserSession.find_by_auth_token(params[:auth_token])
    if user_session.present?
      resp_data  =  Event.global_winners(params, user_session.user)
      render json: resp_data
    else
      resp = {resp_data: {}, resp_status: 0, resp_message: 'error'}
      return render json: resp
    end
  end

  # Call from app
  def leaderboard_winners
    params = {
        "auth_token": UserSession.last.auth_token,
        "page": 2,
        "per_page": 1
    }
    user_session = UserSession.find_by_auth_token(params[:auth_token])
    if user_session.present?
      resp_data  =  Event.leader_winners(params, user_session.user)
      render json: resp_data
    else
      resp = {resp_data: {}, resp_status: 0, resp_message: 'Invalid Token', error: ''}
      return render json: resp
    end
  end
  
  private
  def event_params
    params.require(:event).permit(:name, :location, :start_date, :end_date, :hash_tag)
  end
end
