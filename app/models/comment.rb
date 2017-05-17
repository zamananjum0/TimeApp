class Comment < ApplicationRecord
  
  belongs_to :commentable, polymorphic: true
  belongs_to :member_profile
  
  validates_presence_of :comment, presence: true
  
  @@limit = 10
  
  def self.comment(data, current_user)
    begin
      data        = data.with_indifferent_access
      post      = Post.find_by_id(data[:post][:id])
      comment   = post.comments.build(data[:post][:comment])
      comment.member_profile_id = current_user.profile_id
      if comment.save
        comments        =  Comment.where(id: comment.id)
        resp_data       =  comments_response(comments, current_user, post)
        resp_status     = 1
        resp_request_id = data[:request_id]
        resp_message    = 'Comment Successfully Posted'
        resp_errors     = ''
        response        = JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
        broadcast_response = resp_data
      else
        resp_data       = {}
        resp_request_id = data[:request_id]
        resp_status     = 0
        resp_message    = 'error'
        resp_errors     = 'Comment failed'
        response        = JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
        broadcast_response = false
      end
      [response, broadcast_response]
    rescue Exception => e
      resp_data       = {}
      resp_status     = 0
      resp_message    = 'error'
      resp_errors     = e
      resp_request_id = data[:request_id]
      JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
    end
  end
  
  def self.comments_response(comments, current_user, post=nil)
    comments = comments.as_json(
        only:    [:id, :commentable_id, :commentable_type, :comment, :created_at, :updated_at],
        include: {
            member_profile: {
                only:    [:id, :photo],
                include: {
                    user: {
                        only: [:id, :username]
                    }
                }
            }
        }
    )
    
    status = Like.liked_by_me(post, current_user.profile_id)
    post   = post.as_json(
        only: [:id, :post_title, :post_description, :datetime, :post_datetime, :is_post_public, :created_at, :updated_at, :post_type, :location, :latitude, :longitude],
        methods: [:likes_count, :comments_count, :post_members_counts],
        include: {
            member_profile: {
                only: [:id, :photo],
                include: {
                    user: {
                        only: [:id, :username]
                    }
                }
            },
            post_attachments: {
                only: [:id, :attachment_url, :thumbnail_url, :attachment_type]
            }
        }
    ).merge!(liked_by_me: status)
    { comments: comments, post: post }.as_json
  end
  
  def self.comments_list(data, current_user, sync=nil, session_id=nil)
    begin
      data = data.with_indifferent_access
      max_comment_date = data[:max_comment_date] || Time.now
      min_comment_date = data[:min_comment_date] || Time.now
      
      post     = Post.find_by_id(data[:post][:id])
      comments = post.comments.where(is_deleted: false) if post.present?
     
      if comments.present?
        if data[:max_comment_date].present?
          comments = comments.where("created_at > ?", max_comment_date)
        elsif data[:min_comment_date].present?
          comments = comments.where("created_at < ?", min_comment_date)
        end
        
        comments = comments.order("created_at DESC")
        comments = comments.limit(@@limit)
        
        if comments.present?
          Comment.where("created_at > ? AND commentable_id = ? AND commentable_type = ? ", comments.first.updated_at, comments.first.commentable_id, comments.first.commentable_type).present? ? previous_page_exist = true : previous_page_exist = false
          Comment.where("created_at < ? AND commentable_id = ? AND commentable_type = ? ", comments.last.updated_at, comments.first.commentable_id, comments.first.commentable_type).present? ? next_page_exist = true : next_page_exist = false
        end
        
        resp_data   =  comments_response(comments, current_user, post)
        resp_status     = 1
        resp_message    = 'Comments List'
        resp_errors     = ''
      else
        resp_data       = {}
        resp_status     = 1
        resp_message    = 'Errors'
        resp_errors     = 'No comments found'
      end
      
      if session_id.present?
        resp_data = resp_data.merge!(session_id: session_id)
      end
      paging_data     = {next_page_exist: next_page_exist, previous_page_exist: previous_page_exist}
      resp_request_id = data[:request_id]
      if sync.present?
        JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors, type: "Sync", paging_data: paging_data)
      else
        JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors, paging_data: paging_data)
      end
    rescue Exception => e
      resp_data       = {}
      resp_status     = 0
      paging_data     = ''
      resp_message    = 'error'
      resp_errors     = e
      resp_request_id = data[:request_id]
      JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
    end
  end
  
  def self.broadcast_comment(response, object_id, object_type)
    begin
      resp_message    = 'New Comment Posted'
      resp_request_id = ''
      resp_status     = 1
      resp_errors     = ''
      
      open_sessions = OpenSession.where(media_id: object_id, media_type: AppConstants::POST)
      open_sessions.each do |open_session|
        broadcast_response = response.merge!(session_id: open_session.session_id)
        broadcast_response = JsonBuilder.json_builder(broadcast_response, resp_status, resp_message, resp_request_id, errors: resp_errors, type: "Sync")
        PostJob.perform_later broadcast_response, open_session.user_id
      end
      
    rescue Exception => e
      resp_data       = {}
      resp_status     = 0
      resp_message    = 'error'
      resp_errors     = e
      resp_request_id = data[:request_id]
      JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
    end
  end

  def self.post_comment_notification(post_id, current_user)
    begin
      post                 = Post.find_by_id(post_id)
      post_created_by_user = User.find_by_profile_id(post.member_profile_id)
      profile_ids = post.post_members.pluck(:member_profile_id)
      
      followers_profile_ids = MemberFollowing.where(following_profile_id: post.member_profile_id, following_status: AppConstants::ACCEPTED).pluck(:member_profile_id)
      profile_ids << followers_profile_ids
      profile_ids << post.member_profile_id
      users       = User.where(profile_id: profile_ids.uniq)
      ## ======================== Send Notification ========================
      users && users.each do |user|
        if user != current_user
          name = current_user.username ||  current_user.email
          if user.profile_id == post.member_profile_id
            alert = name + ' ' + AppConstants::POST_COMMENT_YOUR_POST
          else
            if current_user == post_created_by_user
              alert = name + ' ' + AppConstants::POST_COMMENT_OWN
            else
              alert = name + ' ' + 'commented on' + ' ' + post_created_by_user.username || post_created_by_user.email + '\'s poll'
            end
          end
          screen_data = {post_id: post_id}.as_json
          Notification.send_event_notification(user, alert, AppConstants::POST, true, screen_data)
        end
      end
        ## ===================================================================
    rescue Exception => e
      puts e
    end
  end
end
