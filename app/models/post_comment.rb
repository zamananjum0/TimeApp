# class PostComment < ApplicationRecord
#   include JsonBuilder
#   belongs_to :post
#   belongs_to :member_profile
#   @@limit = 10
#
#   def self.post_comment(data, current_user)
#     begin
#       data                           = data.with_indifferent_access
#       post                           = Post.find_by_id(data[:post_id])
#       post_comment                   = post.post_comments.build(data[:post_comment])
#       post_comment.member_profile_id = current_user.profile.id
#       if post_comment.save
#         resp_status     = 1
#         resp_request_id = data[:request_id]
#         resp_message    = 'Comment Successfully Posted'
#         resp_errors     = ''
#         post_comments   = PostComment.where(id: post_comment.id)
#         resp_data       =  posts_comments_response(post_comments, current_user, post)
#       else
#         resp_data       = {}
#         resp_request_id = data[:request_id]
#         resp_status     = 0
#         resp_message    = 'Errors'
#         resp_errors     = 'comment failed'
#       end
#
#       if resp_status == 1
#         response           = JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
#         resp_status        = 1
#         resp_message       = 'New Comment Posted'
#         resp_request_id    = ''
#         resp_errors        = ''
#         broadcast_response = JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors, type: "Sync")
#
#         [response, broadcast_response]
#       else
#         response           = JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
#         [response, false]
#       end
#     rescue Exception => e
#       resp_data       = {}
#       resp_status     = 0
#       paging_data     = ''
#       resp_message    = 'error'
#       resp_errors     = e
#       resp_request_id   = data[:request_id]
#       JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
#     end
#   end
#
#   def self.post_comments_list(data, current_user, sync=nil, session_id=nil)
#     # begin
#       data = data.with_indifferent_access
#       max_comment_date = data[:max_comment_date]
#       min_comment_date = data[:min_comment_date]
#
#       post          = Post.find_by_id(data[:post][:id])
#       post_comments = post.post_comments.where(is_deleted: false) if post.present?
#       if post_comments
#         if data[:max_comment_date].present?
#           post_comments = post_comments.where("created_at > ?", max_comment_date)
#         elsif data[:min_comment_date].present?
#           post_comments = post_comments.where("created_at < ?", min_comment_date)
#         end
#
#         post_comments = post_comments.order("created_at DESC")
#         post_comments = post_comments.limit(@@limit)
#
#         if post_comments.present?
#           PostComment.where("created_at > ? AND post_id = ?", post_comments.first.updated_at, post.id).present? ? previous_page_exist = true : previous_page_exist = false
#           PostComment.where("created_at < ? AND post_id = ?", post_comments.last.updated_at, post.id).present? ? next_page_exist = true : next_page_exist = false
#         end
#
#         paging_data     = {next_page_exist: next_page_exist, previous_page_exist: previous_page_exist}
#         resp_data       = posts_comments_response(post_comments, current_user, post)
#         if session_id.present?
#           resp_data = resp_data.merge!(session_id: session_id)
#         end
#         resp_status     = 1
#         resp_message    = 'Post Comments List'
#         resp_errors     = ''
#       else
#         resp_data       = {}
#         resp_status     = 0
#         paging_data     = ''
#         resp_message    = 'Errors'
#         resp_errors     = 'Post Comments does not exist'
#       end
#
#       resp_request_id = data[:request_id]
#       if sync.present?
#         JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors, type: "Sync", paging_data: paging_data)
#       else
#         JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors, paging_data: paging_data)
#       end
#     # rescue Exception => e
#     #   resp_data       = {}
#     #   resp_status     = 0
#     #   paging_data     = ''
#     #   resp_message    = 'error'
#     #   resp_errors     = e
#     #   resp_request_id = data[:request_id]
#     #   JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
#     # end
#   end
#
#   def self.delete_post_comment(data, current_user)
#     begin
#       data         = data.with_indifferent_access
#       profile      = current_user.profile
#       post_comment = PostComment.find_by_id(data[:post_comment][:id])
#
#       if post_comment.member_profile == profile || post_comment.post.member_profile == profile
#         # post_comment.destroy
#         post_comment.is_deleted = true
#         post_comment.save!
#         resp_status     = 1
#         resp_message    = 'Comment Successfully deleted'
#         resp_errors     = ''
#         resp_data       = ''
#       else
#         resp_data       = ''
#         resp_status     = 0
#         resp_message    = 'Errors'
#         resp_errors     = 'You are not authorized to destroy this comment.'
#       end
#     rescue Exception => e
#       resp_data       = ''
#       resp_status     = 0
#       paging_data     = ''
#       resp_message    = 'error'
#       resp_errors     = e
#     end
#     resp_request_id   = data[:request_id]
#     JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
#   end
#
#   def self.broadcast_comment(response, object_id, object_type)
#     begin
#       resp_message    = 'New Comment Posted'
#       resp_request_id = ''
#       resp_status     = 1
#       resp_errors     = ''
#       if object_type == AppConstants::POST
#         open_sessions = OpenSession.where(media_id: object_id, media_type: AppConstants::POST)
#         open_sessions.each do |open_session|
#           broadcast_response = response.merge!(session_id: open_session.session_id)
#           broadcast_response = JsonBuilder.json_builder(broadcast_response, resp_status, resp_message, resp_request_id, errors: resp_errors, type: "Sync")
#           PostJob.perform_later broadcast_response, open_session.user_id
#         end
#       else
#         open_sessions = OpenSession.where(media_id: object_id, media_type: AppConstants::EVENT)
#         open_sessions.each do |open_session|
#           broadcast_response = response.merge!(session_id: open_session.session_id)
#           broadcast_response = JsonBuilder.json_builder(broadcast_response, resp_status, resp_message, resp_request_id, errors: resp_errors, type: "Sync")
#           PostJob.perform_later broadcast_response, open_session.user_id
#           # EventJob.perform_later broadcast_response, open_session.user_id
#         end
#       end
#     rescue Exception => e
#       resp_data       = {}
#       resp_status     = 0
#       resp_message    = 'error'
#       resp_errors     = e
#       resp_request_id = data[:request_id]
#       JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
#     end
#   end
#
#   # called from controller
#   def self.post_comment_response(post_comment)
#     post_comment = post_comment.as_json(
#         only:    [:id, :post_comment, :is_deleted, :created_at, :updated_at],
#         include: {
#             member_profile: {
#                 only:    [:id, :photo],
#                 include: {
#                     user: {
#                         only: [:id, :first_name, :last_name],
#                         include: {
#                             role: {
#                                 only: [:id, :name]
#                             }
#                         }
#                     }
#                 }
#             },
#             post:           {
#                 only: [:id]
#             }
#         }
#     )
#
#     { post_comment: post_comment }.as_json
#   end
#
#   def self.posts_comments_response(post_comments_array, current_user, post=nil)
#     post_comments = post_comments_array.as_json(
#         only:    [:id, :post_id, :post_comment, :created_at, :updated_at],
#         include: {
#             member_profile: {
#                 only:    [:id, :photo],
#                 include: {
#                     user: {
#                         only: [:id, :username, :email]
#                     }
#                 }
#             }
#         }
#     )
#
#     if post.present?
#       post_like = post.post_likes.where(member_profile_id: current_user.profile.id).try(:first)
#       if post_like && post_like.is_like
#         status = true
#       else
#         status = false
#       end
#       post = post.as_json(
#           only: [:id, :post_title, :post_type],
#           methods: [:likes_count, :comments_count, :post_members_counts],
#           include: {
#               member_profile: {
#                   only: [:id, :photo],
#                   include: {
#                       user: {
#                           only: [:id, :username, :email]
#                       }
#                   }
#               },
#               post_attachments: {
#                   only: [:id, :attachment_url, :thumbnail_url, :attachment_type]
#               }
#           }
#       ).merge!(liked_by_me: status)
#       { post_comments: post_comments, post: post }.as_json
#     else
#       { post_comments: post_comments}.as_json
#     end
#   end
# end
#
# # == Schema Information
# #
# # Table name: post_comments
# #
# #  id                :integer          not null, primary key
# #  post_id           :integer
# #  member_profile_id :integer
# #  post_comment      :text
# #  created_at        :datetime         not null
# #  updated_at        :datetime         not null
# #  is_deleted        :boolean          default(FALSE)
# #
