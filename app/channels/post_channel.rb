class PostChannel < ApplicationCable::Channel
  # after_subscribe :newly_created_posts

  def subscribed
    if params[:post_id].present?
      stream_from "post_#{params[:post_id]}"
      sync_comments(current_user, params[:post_id], params[:session_id])
    elsif current_user.present?
      stream_from "post_channel_#{current_user.id}"
      newly_created_posts(current_user)
    else
      current_user = find_verified_user
      stream_from "post_channel_#{current_user.id}"
    end
  end

  def unsubscribed
    if params[:post_id].present?
      open_sessions = OpenSession.where(user_id: current_user.id, media_id: params[:post_id], media_type: AppConstants::POST)
    end
    open_sessions.destroy_all if open_sessions.present?
    current_user.last_subscription_time = Time.now
    current_user.save!
    stop_all_streams
  end

  def sync_comments(current_user, object_id, session_id)
    params = {user_id: current_user.id, media_id: object_id, media_type: AppConstants::POST}
    open_session = OpenSession.find_by_user_id_and_media_id(current_user.id, object_id) || OpenSession.new(params)
    open_session.session_id = session_id
    open_session.save
    data  = { post: { id: object_id } }
    
    response = Comment.comments_list(data, current_user, true, session_id)
    PostJob.perform_later response, current_user.id
  end

  def post_create(data)
    response = Post.post_create(data, current_user)
    PostJob.perform_later response, current_user.id
    json_obj = JSON.parse(response)
    post_id  = json_obj['data']['post']['id'] if json_obj['data']['post'].present?
    if post_id.present?
      Post.post_sync(post_id, current_user)
    end
  end

  # def post_destroy(data)
  #   response = Post.post_destroy(data, current_user)
  #   PostJob.perform_later response, current_user.id
  # end
  
  def newly_created_posts(current_user)
    response = Post.newly_created_posts(current_user)
    PostJob.perform_later response, current_user.id if response.present?
  end

  def like(data)
    response, resp_broadcast = Like.like(data, current_user)
    PostJob.perform_later response, current_user.id
    json_obj = JSON.parse(response)
    if json_obj["message"] == AppConstants::LIKED
      object_id   = json_obj['data']['like']['likable_id']
      object_type = json_obj['data']['like']['likable_type']
      Like.broadcast_like(resp_broadcast, object_id,  object_type)
    end
  end

  def comment(data)
    response, broadcast_response = Comment.comment(data, current_user)
    PostJob.perform_later response, current_user.id
    if broadcast_response.present?
      json_obj = JSON.parse(response)
      object_id   = json_obj['data']['comments'][0]['commentable_id']
      object_type = json_obj['data']['comments'][0]['commentable_type']
      Comment.broadcast_comment(broadcast_response, object_id,  object_type)
    end
  end
  
  def sync_akn(data)
    response = Post.sync_ack(data, current_user)
    PostJob.perform_later response, current_user.id
  end
  
  protected
  def find_verified_user
    user_session = UserSession.find_by_auth_token(params[:auth_token])

    if user_session.present?
      user_session.user
    else
      reject_unauthorized_connection
    end
  end
end
