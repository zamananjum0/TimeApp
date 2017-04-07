class Api::V1::UsersController < Api::V1::ApiProtectedController
  
  # calling from web
  def index
    member_profiles =  MemberProfile.all
    member_profiles =  member_profiles.page(params[:page].to_i).per_page(params[:per_page].to_i)
    paging_data     = get_paging_data(params[:page], params[:per_page], member_profiles)
    member_profiles =  member_profiles.as_json(
        only: [:id, :photo, :is_profile_public],
        methods: [:posts_count, :followings_count, :followers_count],
        include: {
            user: {
                only: [:id, :profile_id, :profile_type, :email, :username, :is_deleted]
            }
        }
    )
    resp_data    = {member_profiles: member_profiles}.as_json
    resp_status  = 1
    resp_message = 'Success'
    resp_errors  = ''
    common_api_response(resp_data, resp_status, resp_message, resp_errors, paging_data)
  end
  
  # calling from web
  def user_posts
    member_profile = MemberProfile.find_by_id(params[:member_profile_id])
    if member_profile.present?
      posts        =  member_profile.posts
      posts        =  posts.page(params[:page].to_i).per_page(params[:per_page].to_i)
      paging_data  =  get_paging_data(params[:page], params[:per_page], posts)
      resp_data    =  Post.posts_array_response(posts, member_profile)
      resp_status  = 1
      resp_message = 'Success'
      resp_errors  = ''
    else
      paging_data  = ''
      resp_data    = {}
      resp_status  = 0
      resp_message = 'error'
      resp_errors  = 'User not found'
    end
    common_api_response(resp_data, resp_status, resp_message, resp_errors, paging_data)
  end
  
  # calling from web
  def user_followers
    member_profile = MemberProfile.find_by_id(params[:member_profile_id])
    if member_profile.present?
      member_followers =  MemberFollowing.where(following_profile_id: member_profile.id)
      member_followers =  member_followers.page(params[:page].to_i).per_page(params[:per_page].to_i)
      paging_data      =  get_paging_data(params[:page], params[:per_page], member_followers)
      member_followers =  member_followers.as_json(
          only: [:id, :following_status],
          include:{
              member_profile:{
                  only:[:id],
                  include:{
                      user:{
                          only:[:id, :email, :username]
                      }
                  }
              }
          }
      )
      resp_data    =  {member_followers: member_followers}.as_json
      resp_status  = 1
      resp_message = 'Success'
      resp_errors  = ''
    else
      paging_data  = ''
      resp_data    = {}
      resp_status  = 0
      resp_message = 'error'
      resp_errors  = 'User not found'
    end
    common_api_response(resp_data, resp_status, resp_message, resp_errors, paging_data)
  end
  
  # Call from web
  def block_user
    user = User.find_by_id(params[:user_id])
    if user.present?
      user.is_deleted = params[:is_block]
      user.save!
      resp_data    =  {}
      resp_status  = 1
      resp_message = 'Success'
      resp_errors  = ''
    else
      resp_data    =  {}
      resp_status  = 0
      resp_message = 'error'
      resp_errors  = 'User not found.'
    end
    common_api_response(resp_data, resp_status, resp_message, resp_errors)
  end
  
end
