class PostChannel < ApplicationCable::Channel
  # after_subscribe :newly_created_posts

  def subscribed
    if params[:post_id].present?
      stream_from "post_#{params[:post_id]}"
    elsif current_user.present?
      stream_from "post_channel_#{current_user.id}"
      newly_created_posts(current_user)
    else
      current_user = find_verified_user
      stream_from "post_channel_#{current_user.id}"
    end
  end

  def unsubscribed
    current_user.last_subscription_time = Time.now
    current_user.save!
    stop_all_streams
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

  def post_destroy(data)
    response = Post.post_destroy(data, current_user)
    PostJob.perform_later response, current_user.id
  end
  
  def newly_created_posts(current_user)
    response = Post.newly_created_posts(current_user)
    PostJob.perform_later response, current_user.id if response.present?
  end

  def post_like(data)
    response, resp_broadcast = PostLike.post_like(data, current_user)
    PostJob.perform_later response, current_user.id
    json_obj = JSON.parse(response)
    post_id  = json_obj["data"]["post_like"]["post"]["id"]
    PostJob.perform_later resp_broadcast, '', post_id
  end

  def post_comment(data)
    response, broadcast_response = PostComment.post_comment(data, current_user)
    PostJob.perform_later response, current_user.id
    if broadcast_response.present?
      json_obj = JSON.parse(response)
      post_id  = json_obj["data"]["post_comments"][0]["post_id"]
      PostJob.perform_later broadcast_response, '', post_id
    end
  end

  def delete_post_comment(data)
    response = PostComment.delete_post_comment(data, current_user)
    PostJob.perform_later response, current_user.id
  end
  
  # def sync_post_likes(current_user, post_id)
  #   data     = { post: { id: post_id } }
  #   response = PostLike.post_likes_list(data, current_user, true)
  #   PostJob.perform_later response, current_user.id
  # end

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
