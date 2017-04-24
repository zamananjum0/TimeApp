class Api::V1::GroupsController < ApplicationController
  
  def index
    # params ={
    #   auth_token: UserSession.last.auth_token,
    #   "per_page": 10,
    #   "page": 1,
    # }
    user_session = UserSession.find_by_auth_token(params[:auth_token])
    if user_session.present?
      resp_data  =  Group.group_list(params, user_session.user)
      render json: resp_data
    else
      resp_data = {resp_data: {}, resp_status: 0, resp_message: 'Invalid Token', resp_error: 'error'}.as_json
      return render json: resp_data
    end
  end

  def create
    # params ={
    #   auth_token: UserSession.last.auth_token,
    #   group:{
    #       name: 'Cricket',
    #       group_members_attributes:[
    #          {
    #              member_profile_id: '5d40d57e-7564-4a84-ae04-f907605cd880'
    #          }
    #       ]
    #   }
    # }
    user_session = UserSession.find_by_auth_token(params[:auth_token])
    if user_session.present?
      resp_data  =  Group.create_group(params, user_session.user)
      render json: resp_data
    else
      resp_data = {resp_data: {}, resp_status: 0, resp_message: 'Invalid Token', resp_error: 'error'}.as_json
      return render json: resp_data
    end
  end

  def update_group
    # params ={
    #   "auth_token": UserSession.last.auth_token,
    #   "group":{
    #       "id": "896d2d7b-6f29-4a45-9459-618b8b4bddf2",
    #       "name": "Book Gala"
    #   },
    #   "group_members":["68fffa3b-c53b-4509-8263-2a41441abbed"]
    # }
    user_session = UserSession.find_by_auth_token(params[:auth_token])
    if user_session.present?
      resp_data  =  Group.update_group(params, user_session.user)
      render json: resp_data
    else
      resp_data = {resp_data: {}, resp_status: 0, resp_message: 'Invalid Token', resp_error: 'error'}.as_json
      return render json: resp_data
    end
  end
  
  def delete_group
    # params ={
    #   auth_token: UserSession.last.auth_token,
    #   "id": "896d2d7b-6f29-4a45-9459-618b8b4bddf2"
    # }
    user_session = UserSession.find_by_auth_token(params[:auth_token])
    if user_session.present?
      resp_data  =  Group.delete_group(params, user_session.user)
      render json: resp_data
    else
      resp_data = {resp_data: {}, resp_status: 0, resp_message: 'Invalid Token', resp_error: 'error'}.as_json
      return render json: resp_data
    end
  end
end
