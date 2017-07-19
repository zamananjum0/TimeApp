class Post < ApplicationRecord

  include JsonBuilder
  include PgSearch

  belongs_to :member_profile
  has_many   :post_members,     dependent: :destroy
  has_many   :post_attachments, dependent: :destroy
  has_many   :comments,         dependent: :destroy, as: :commentable
  has_many   :likes,            dependent: :destroy, as: :likable
  has_many   :recent_comments, -> { order(created_at: :desc).limit(10) }, class_name: 'Comment', as: :commentable
  has_many   :recent_likes,    -> { order(created_at: :desc).limit(10) }, class_name: 'Like',    as: :likable

  
  has_many :hashtags,   through:   :media_tags
  has_many :media_tags, as: :media, dependent: :destroy
  accepts_nested_attributes_for :post_attachments, :post_members
  
  @@limit = 10
  @@current_profile = nil
  after_commit :process_hashtags
  
  pg_search_scope :search_by_title,
    against: [:post_description, :post_title],
    using: {
        tsearch:{
            any_word: true,
            dictionary: 'english'
        }
    }

  def process_hashtags
    arr = []
    hashtag_regex = /\B#\w\w+/
    text_hashtags_title = post_description.scan(hashtag_regex) if post_description.present?
    if text_hashtags_title.present?
      arr << text_hashtags_title
      tags = (arr.flatten).uniq
      ids = []
      tags && tags.each do |ar|
        tag = Hashtag.where("lower(name) = ?", ar.downcase).try(:first)
        if tag.present?
          tag.count = tag.count + 1
          tag.save!
        else
          tag = Hashtag.create!(name: ar.downcase)
        end
        media_tag = MediaTag.find_by_media_id_and_media_type_and_hashtag_id(self.id, AppConstants::POST, tag.id)
        if media_tag.blank?
          MediaTag.create!(media_id: self.id, media_type: AppConstants::POST, hashtag_id: tag.id)
        end
        ids << tag.id
      end
      if ids.present?
        MediaTag.where("media_id = ? AND hashtag_id NOT IN(?)", self.id, ids).try(:destroy_all)
      end
    end
  end
  
  def self.post_create(data, current_user)
    begin
      data = data.with_indifferent_access
      profile = current_user.profile
      post = profile.posts.build(data[:post])
      if profile.posts.count < profile.remaining_posts_count
        if post.save
          resp_data       = post.post_response
          resp_status     = 1
          resp_message    = 'Post Created'
          resp_errors     = ''
        else
          resp_data       = {}
          resp_status     = 0
          resp_message    = 'Errors'
          resp_errors     = post.errors.messages
        end
      else
        resp_data       = {}
        resp_status     = 1
        resp_message    = 'You are exceeding your posts limit'
        resp_errors     = ''
      end
    rescue Exception => e
      resp_data       = {}
      resp_status     = 0
      resp_message    = 'error'
      resp_errors     = e
    end
    resp_request_id = data[:request_id]
    JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
  end

  def post_response
    post = self.as_json(
        only: [:id, :post_title, :post_description],
        methods: [:likes_count, :comments_count],
        include: {
            member_profile: {
                only: [:id, :photo],
                include: {
                    user: {
                        only: [:id, :username, :email]
                    }
                }
            },
            post_attachments: {
                only: [:attachment_url, :thumbnail_url, :attachment_type, :width, :height]
            },
            recent_comments: {
                only: [:id, :comment],
                include: {
                    member_profile: {
                        only: [:id, :photo],
                        include: {
                            user: {
                                only: [:id, :username, :email]
                            }
                        }
                    }
                }
            },
            recent_likes: {
                only: [:id],
                include: {
                    member_profile: {
                        only: [:id, :photo],
                        include: {
                            user: {
                                only: [:id, :username, :email]
                            }
                        }
                    }
                }
            }
        }
    )

    {post: post}.as_json
  end
  
  def self.post_show(data, current_user)
    begin
      post = Post.find_by_id(data[:id])
      if post.present?
        resp_data       = post.post_response
        resp_status     = 1
        resp_message    = 'Post'
        resp_errors     = ''
      else
        resp_data       = {}
        resp_status     = 0
        resp_message    = 'Post not found'
        resp_errors     = ''
      end
    rescue Exception => e
      resp_data       = {}
      resp_status     = 0
      resp_message    = 'error'
      resp_errors     = e
    end
    resp_request_id   = data[:request_id] || ''
    JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
  end

  def self.post_destroy(data, current_user)
    begin
      data = data.with_indifferent_access
      post = Post.find_by_id(data[:post][:id])
      post.is_deleted = true
      post.save!
      resp_status = 1
      resp_message = 'Post deleted'
      resp_errors = ''
      resp_data = ''
    rescue Exception => e
      resp_data       = ''
      resp_status     = 0
      paging_data     = ''
      resp_message    = 'error'
      resp_errors     = e
    end
    resp_request_id   = data[:request_id]
    JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
  end

  def self.posts_array_response(post_array, profile, sync_token=nil)
    @@current_profile = profile
    posts = post_array.as_json(
        only: [:id, :post_description, :created_at, :updated_at, :is_deleted, :event_id],
        methods: [:likes_count, :liked_by_me, :comments_count],
        include: {
            member_profile: {
                only: [:id, :photo],
                include: {
                    user: {
                        only: [:id, :username, :email]
                    }
                }
            },
            post_attachments: {
                only: [:id, :attachment_url, :thumbnail_url, :created_at, :updated_at, :attachment_type, :width, :height]
            }
        }
    )

    if sync_token.present?
      {sync_token: sync_token, posts: posts}.as_json
    else
      {posts: posts}.as_json
    end
  end

  def self.post_list(data, current_user)
    begin
      data = data.with_indifferent_access
      max_post_date = data[:max_post_date] || Time.now
      min_post_date = data[:min_post_date] || Time.now
      profile = current_user.profile
      following_ids   = profile.member_followings.where(following_status: AppConstants::ACCEPTED).pluck(:following_profile_id)
      post_ids        = PostMember.where(member_profile_id: profile.id).pluck(:post_id)
      following_ids   << profile.id
      member_ids   = following_ids.flatten.uniq
      posts        = Post.where("(member_profile_id IN (?) OR id IN (?)) AND is_deleted = ?", member_ids, post_ids, false).distinct

      if data[:search_key].present?
        posts  = posts.where('lower(post_description) like ?', "%#{data[:search_key]}%".downcase)
      end
      
      if data[:max_post_date].present?
        posts = posts.where("created_at > ?", max_post_date)
      elsif data[:min_post_date].present?
        posts = posts.where("created_at < ?", min_post_date)
      end
      
      posts = posts.order("created_at DESC")
      posts = posts.limit(@@limit)

      if posts.present?
        Post.where("created_at > ?", posts.first.created_at).present? ? previous_page_exist = true : previous_page_exist = false
        Post.where("created_at < ?", posts.last.created_at).present? ? next_page_exist = true : next_page_exist = false
      end
      paging_data = {next_page_exist: next_page_exist || false, previous_page_exist: previous_page_exist || false}
      resp_data   = posts_array_response(posts, profile)
      resp_status = 1
      resp_message= 'Post list'
      resp_errors = ''
    rescue Exception => e
      resp_data       = {}
      resp_status     = 0
      paging_data     = ''
      resp_message    = 'error'
      resp_errors     = e
    end
    resp_request_id   = data[:request_id]
    JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors, paging_data: paging_data)
  end

  def self.post_sync(post_id, current_user)
    posts = Post.where(id: post_id)
    make_post_sync_response(current_user, posts)
    member_profile_ids = []
    member_profile_ids << posts.first.post_members.pluck(:member_profile_id)

    # Followers
    member_profile_ids << MemberFollowing.where("following_profile_id = ? AND following_status = ? ", current_user.profile_id, AppConstants::ACCEPTED).pluck(:member_profile_id)
    users = User.where(profile_id: member_profile_ids.flatten.uniq)
    
    users && users.each do |user|
      if user != current_user
        make_post_sync_response(user, posts)
      end
    end
    users
  end

  def self.make_post_sync_response(user, posts)
    resp_data = Synchronization.sync_response(user.profile, posts, 'Posts')
    profile = user.profile
    sync_object             = profile.synchronizations.first ||  profile.synchronizations.build
    sync_object.sync_token  = SecureRandom.uuid
    sync_object.synced_date = posts.first.updated_at
    sync_object.save!

    resp_data = posts_array_response(posts, profile, sync_object.sync_token)
    resp_status = 1
    resp_request_id = ''
    resp_message = 'Posts'
    resp_errors = ''
    response = JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors, type: "Sync")
    PostJob.perform_later response, user.id
    # PostJob.perform_later response, users
  end

  def self.newly_created_posts(current_user)
    begin
      last_subs_date = current_user.last_subscription_time
      profile = current_user.profile

      # following_ids   = profile.member_followings.where(following_status: AppConstants::ACCEPTED).pluck(:following_profile_id)
      # post_ids        = PostMember.where(member_profile_id: profile.id).pluck(:post_id)
      # following_ids   << profile.id
      # member_ids   = following_ids.flatten.uniq
      # posts        = Post.where("(member_profile_id IN (?) OR id IN (?)) AND is_deleted = ?", member_ids, post_ids, false).distinct
      #   Temporarily
      posts = Post.all
      if current_user.current_sign_in_at.blank? && last_subs_date.present? && TimeDifference.between(Time.now, last_subs_date).in_minutes < 30
        if current_user.synced_datetime.present?
          posts = posts.where("created_at > ?", current_user.synced_datetime)
          posts = posts.order("created_at DESC")
          start = false
        else
          posts = posts.order("created_at DESC")
          posts = posts.limit(@@limit)
          start = 'start_sync'
          if posts.present?
            Post.where("created_at < ?", posts.last.created_at).present? ? next_page_exist = true : next_page_exist = false
          end
        end
      else
        posts = posts.order("created_at DESC")
        posts = posts.limit(@@limit)
        start = 'start_sync'
        if posts.present?
          Post.where("created_at < ?", posts.last.created_at).present? ? next_page_exist = true : next_page_exist = false
        end
      end

      if current_user.current_sign_in_at.present?
        current_user.current_sign_in_at = nil
        current_user.save!
      end

      if posts.present?
        # Create sync object
        sync_object             = profile.synchronizations.first ||  profile.synchronizations.build
        sync_object.sync_token  = SecureRandom.uuid
        sync_object.synced_date = posts.first.updated_at
        sync_object.save!

        paging_data = {next_page_exist: next_page_exist}
        resp_data = posts_array_response(posts, profile, sync_object.sync_token)
        resp_status = 1
        resp_request_id = ''
        resp_message = 'Posts'
        resp_errors = ''
        if start == 'start_sync'
          JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors, start: start, type: "Sync", paging_data: paging_data)
        else
          JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors, start: start, type: "Sync")
        end
      else
        resp_data       = {}
        resp_status     = 0
        resp_request_id = ''
        resp_message    = 'Posts Not Found'
        resp_errors     = ''
        JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
      end
    rescue Exception => e
      resp_data       = {}
      resp_status     = 0
      paging_data     = ''
      resp_message    = 'error'
      resp_errors     = e
      JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
    end
  end

  def self.sync_ack(data,current_user)
    data        =  data.with_indifferent_access
    sync_object =  Synchronization.find_by_sync_token(data[:synchronization][:sync_token])
    if sync_object.present?
      current_user.synced_datetime = sync_object.synced_date
      if current_user.save
        sync_object.destroy
      end
    end
  end

  def likes_count
    self.likes.where(is_like: true, is_deleted: false).count
  end

  def liked_by_me
    post_like = self.likes.where(member_profile_id: @@current_profile.id).try(:first)
    if post_like && post_like.is_like
      true
    else
      false
    end
  end

  def post_members_counts
    self.post_members.count
  end

  def comments_count
    self.comments.where(is_deleted: false).count
  end
  
  def self.timeline_posts_array_response(posts, profile, current_user)
    @@current_profile = profile
    posts = posts.as_json(
        only: [:id, :post_title, :created_at, :updated_at],
        methods: [:likes_count,  :liked_by_me, :comments_count],
        include: {
            member_profile:{
              only:[:id, :photo],
              include:{
                  user: {
                      only: [:id, :username, :email]
                  }
              }
            },
            recent_likes: {
                only: [:id, :created_at, :updated_at],
                include: {
                    member_profile: {
                        only: [:id, :photo],
                        include: {
                            user: {
                                only: [:id, :username, :email]
                            }
                        }
                    }
                }
            },
            post_members: {
                only: [:id, :created_at, :updated_at],
                include: {
                    member_profile: {
                        only: [:id, :photo],
                        include: {
                            user: {
                                only: [:id, :username, :email]
                            }
                        }
                    }
                }
            },
            post_attachments: {
                only: [:id, :attachment_url, :thumbnail_url, :created_at, :updated_at, :attachment_type, :width, :height]
            }
        }
    )

    is_following = MemberProfile.is_following(profile, current_user)
    member_profile = profile.as_json(
        only: [:id, :photo],
        include: {
            user: {
                only: [:id, :email, :username]
            }
        }
    ).merge!(is_im_following: is_following)
    {posts: posts, member_profile: member_profile}.as_json
  end

  def self.paging_records(member_profiles, posts, hash_tags, larger_array_type)
    if larger_array_type == 'Member'
      member_profiles
    elsif larger_array_type == 'Post'
      posts
    elsif larger_array_type == 'Hashtag'
      hash_tags
    end
  end
  
  def self.re_post(data, current_user)
    begin
      data = data.with_indifferent_access
      post    = Post.find_by_id(data[:post_id])
      if post.present?
        profile = current_user.profile
        new_post = profile.posts.build
        
        new_post.post_description = post.post_description
        new_post.post_type  = post.post_type
        new_post.save!
        
        post_members     = post.post_members
        post_attachments = post.post_attachments
        post_members&.each do |post_member|
          new_post_member = new_post.post_members.build
          new_post_member.member_profile_id = post_member.member_profile_id
          new_post_member.save!
        end
  
        post_attachments&.each do |attachment|
          new_post_attachment = new_post.post_attachments.build
          new_post_attachment.attachment_url  = attachment.attachment_url
          new_post_attachment.thumbnail_url   = attachment.thumbnail_url
          new_post_attachment.attachment_type = attachment.attachment_type
          new_post_attachment.width           = attachment.width
          new_post_attachment.height           = attachment.height
          new_post_attachment.save!
        end
        resp_data = {}
        resp_status = 1
        resp_message = 'Post created'
        resp_errors = ''
      else
        resp_data = {}
        resp_status = 0
        resp_message = 'Post not created'
        resp_errors = 'errors'
      end
    rescue Exception => e
      resp_data       = {}
      resp_status     = 0
      resp_message    = 'error'
      resp_errors     = e
    end
    resp_request_id   = data[:request_id]
    response = JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
    [response, new_post]
  end

  def self.post_creation_notification(post_id, current_user, reciever_users)
    ## ======================== Send Notification ========================
    reciever_users&.each do |reciever_user|
      name = current_user.username || current_user.full_name || current_user.email
      alert = name + ' ' + AppConstants::NEW_POST
      screen_data = {post_id: post_id}.as_json
      Notification.send_event_notification(reciever_user, alert, AppConstants::POST, true, screen_data)
    end
    ## ===================================================================
  end
end

# == Schema Information
#
# Table name: posts
#
#  id                :integer          not null, primary key
#  member_profile_id :integer
#  post_title        :string
#  post_datetime     :datetime
#  post_description  :text
#  is_post_public    :boolean
#  is_deleted        :boolean          default(FALSE)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  post_type         :string
#  location          :string
#  latitude          :float
#  longitude         :float
#

