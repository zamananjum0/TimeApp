class Post < ApplicationRecord

  include JsonBuilder
  include PgSearch

  belongs_to :member_profile
  has_many :post_videos, dependent: :destroy
  has_many :post_members, dependent: :destroy
  has_many :post_users, dependent: :destroy
  has_many :post_attachments, dependent: :destroy
  has_many :album_images, dependent: :destroy
  has_many :post_likes, dependent: :destroy
  has_many :recent_post_likes, -> { order(created_at: :desc).limit(5) }, class_name: 'PostLike'
  has_many :post_comments, dependent: :destroy
  has_many :recent_post_comments, -> { order(created_at: :desc).limit(5) }, class_name: 'PostComment'

  # has_many :recent_reported_posts, -> { order(created_at: :desc).limit(5) }, class_name: 'ReportPost'
  # has_many :report_posts, dependent: :destroy
  # has_many :reports, as: :reportable


   accepts_nested_attributes_for :post_videos, :post_attachments, :post_members, :post_users

  validates :is_post_public, inclusion: {in: [true, false]}

  after_commit :process_hashtags
  @@limit = 10
  @@current_profile = nil



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
    hashtag_regex, current_user = /\B#\w\w+/
    text_hashtags_title = post_title.scan(hashtag_regex) if post_title.present?
    text_hashtags_description = post_description.scan(hashtag_regex) if post_description.present?
    arr << text_hashtags_title
    arr << text_hashtags_description
    tags = (arr.flatten).uniq
    tags.each do |ar|
      tag_name = Hashtag.find_by_name(ar)
      if tag_name.present?
        tag_name.count = tag_name.count+1
        tag_name.save!
      else
        Hashtag.create name: ar
      end
    end
  end

  def self.post_create(data, current_user)
     begin
      data = data.with_indifferent_access
      profile = current_user.profile
      post = profile.posts.build(data[:post])
      if post.save
        # if data[:album_id].present?
        #   album   = current_user.profile.user_albums.find_by_id(data[:album_id])
        # else
        #   album   = current_user.profile.user_albums.find_by_default_album(true)
        # end
        # response        = post_to_timeline_album(album, post, current_user)
        resp_data       = post.post_response
        resp_status     = 1
        resp_message    = 'Post Created'
        resp_errors     = ''
      else
        resp_data       = ''
        resp_status     = 0
        resp_message    = 'Errors'
        resp_errors     = post.errors.messages
      end
    rescue Exception => e
      resp_data       = ''
      resp_status     = 0
      paging_data     = ''
      resp_message    = 'error'
      resp_errors     = e
    end
    resp_request_id = data[:request_id]
    JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
  end

  def post_response
    post = self.as_json(
        only: [:id, :post_title, :post_description, :datetime, :post_datetime, :is_post_public],
         methods: [:likes_count],
        include: {
            member_profile: {
                only: [:id, :about, :phone, :photo, :country_id, :is_profile_public, :gender, :dob],
                include: {
                    user: {
                        only: [:id, :first_name, :last_name],
                        include:{
                            # role: {
                            #     only:[:id, :name]
                            # }
                    }
                }
            }
        },
        post_attachments: {
            only: [:attachment_url, :thumbnail_url, :attachment_type],
            include:{
                post_photo_users:{
                    only:[:id, :member_profile_id],
                    include: {
                        member_profile: {
                            only: [:id],
                            include: {
                                user: {
                                    only: [:id, :first_name, :last_name]
                                }
                            }
                        }
                    }
                }
            }
        },
        recent_post_comments: {
            only: [:id, :post_comment],
            include: {
                member_profile: {
                    only: [:id, :about, :phone, :photo, :country_id, :gender],
                    include: {
                        user: {
                            only: [:id, :first_name, :last_name],
                            include:{
                                # role: {
                                #     only:[:id, :name]
                                # }
                            }
                        }
                    }
                }
            }
        },
        recent_post_likes: {
            only: [:id],
            include: {
                member_profile: {
                    only: [:id, :about, :phone, :photo, :country_id, :gender],
                    include: {
                        user: {
                            only: [:id, :first_name, :last_name],
                            include:{
                                # role: {
                                #     only:[:id, :name]
                                # }
                            }
                        }
                    }
                }
            }
        }
      }
    )

    {post: post}.as_json
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

  def self.post_update(data, current_user)
    begin
      data = data.with_indifferent_access
      post = current_user.profile.posts.where(id: data[:post][:id]).try(:first)
      if post
        post.update_attributes(data[:post])
        resp_data = post.post_response
        resp_status = 1
        resp_message = 'Updated Successfully'
        resp_errors = ''
      else
        resp_data = ''
        resp_status = 0
        resp_message = 'Errors'
        resp_errors = 'Post Does not exist'
      end
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

  def self.post_show(data, current_user)
    begin
      data = data.with_indifferent_access
      post = Post.find_by_id(data[:post][:id])
      if post
        resp_data       = post_and_related_posts(post,post.post_title)
        resp_data = post.post_response
        resp_status = 1
        resp_message = 'success'
        resp_errors = ''
      else
        resp_data = ''
        resp_status = 0
        resp_message = 'Errors'
        resp_errors = 'Post Does not exist'
      end
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
        only: [:id, :post_title, :post_description, :datetime, :is_post_public, :is_deleted, :created_at, :updated_at, :post_type, :location],
        methods: [:likes_count, :liked_by_me],
        include: {
            member_profile: {
                only: [:id, :about, :phone, :photo, :country_id, :is_profile_public, :gender,],
                include: {
                    user: {
                        only: [:id, :first_name, :last_name]
                    }
                }
            },
            recent_post_comments: {
                only: [:id, :post_comment, :created_at, :updated_at],
                include: {
                    member_profile: {
                        only: [:id, :about, :phone, :photo, :country_id, :is_profile_public, :gender],
                        include: {
                            user: {
                                only: [:id, :first_name, :last_name, :banner_image_1, :banner_image_2, :banner_image_3]
                            }
                        }
                    }
                }
            },
            recent_post_likes: {
                only: [:id, :created_at, :updated_at],
                include: {
                    member_profile: {
                        only: [:id, :photo],
                        include: {
                            user: {
                                only: [:id, :email, :first_name, :last_name, :banner_image_1, :banner_image_2, :banner_image_3]
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
                                only: [:id, :first_name, :last_name]
                            }
                        }
                    }
                }
            },
            post_attachments: {
                only: [:id, :attachment_url, :thumbnail_url, :created_at, :updated_at, :attachment_type],
                include:{
                    post_photo_users:{
                        only:[:id, :member_profile_id, :post_attachment_id],
                        include: {
                            member_profile: {
                                only: [:id],
                                include: {
                                    user: {
                                        only: [:id, :first_name, :last_name]
                                    }
                                }
                            }
                        }
                    }
                }
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
      resp_data = posts_array_response(posts, profile)
      resp_status = 1
      resp_message = 'Post list'
      resp_errors = ''
    rescue Exception => e
      resp_data       = ''
      resp_status     = 0
      paging_data     = ''
      resp_message    = 'error'
      resp_errors     = e
    end
    resp_request_id   = data[:request_id]
    JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors, next_page_exist: next_page_exist, previous_page_exist: previous_page_exist, post_list: true)
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

  end

  def self.make_post_sync_response(user, posts)
    resp_data = Synchronization.sync_response(user.profile, posts, 'Posts')
    profile = user.profile
    sync_object             = profile.synchronizations.first ||  profile.synchronizations.build
    sync_object.sync_token  = SecureRandom.uuid
    sync_object.synced_date = posts.first.updated_at
    sync_object.save!

    # resp_data = posts_array_response(posts, profile, sync_object.sync_token)
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

      following_ids   = profile.member_followings.where(following_status: AppConstants::ACCEPTED).pluck(:following_profile_id)
      post_ids        = PostMember.where(member_profile_id: profile.id).pluck(:post_id)
      following_ids   << profile.id
      member_ids   = following_ids.flatten.uniq
      posts        = Post.where("(member_profile_id IN (?) OR id IN (?)) AND is_deleted = ?", member_ids, post_ids, false).distinct

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

        resp_data = posts_array_response(posts, profile, sync_object.sync_token)
        resp_status = 1
        resp_request_id = ''
        resp_message = 'Posts'
        resp_errors = ''
        if start == 'start_sync'
          JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors, start: start, type: "Sync", next_page_exist: next_page_exist, post_list: true)
        else
          JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors, start: start, type: "Sync")
        end
      else
        resp_data = ''
        resp_status = 0
        resp_request_id = ''
        resp_message = 'Posts Not Found'
        resp_errors = ''
        JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
      end
    rescue Exception => e
      resp_data       = ''
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
    self.post_likes.where(like_status: true, is_deleted: false).count
  end

  def liked_by_me
    post_like = self.post_likes.where(member_profile_id: @@current_profile.id).try(:first)
    if post_like && post_like.like_status
      true
    else
      false
    end
  end

  def post_members_counts
    self.post_members.count
  end

  def comments_count
    self.post_comments.where(is_deleted: false).count
  end

  def self.related_posts(data, current_user)
    begin
      data = data.with_indifferent_access

      per_page = (data[:per_page] || 20).to_i
      page = (data[:page] || 1).to_i

      post = Post.find_by_id(data[:post][:id])
      if post.present?
        post.post_description.present? ? search_key = post.post_description : search_key = post.post_title
        # posts = PgSearch.multisearch(search_key)
        # posts = related_post_search(posts)
        posts  = Post.search_by_title(search_key)


        related_post_ids         = posts.pluck(:id)
        nearest_posts            = Post.within(5, origin: [post.latitude, post.longitude])
        nearest_related_posts    = nearest_posts.where(id: related_post_ids)
        nearest_related_post_ids = nearest_related_posts.pluck(:id)

        filtered_posts = posts.reject { |h| nearest_related_post_ids.include? h['id'] }

        post_array = []
        post_array << nearest_related_posts
        post_array << filtered_posts
        post_array = post_array.flatten

        post_array = post_array.drop((page-1)*per_page)
        post_array = post_array.take(per_page)

        posts       = posts.page(page.to_i).per_page(per_page.to_i)
        paging_data = JsonBuilder.get_paging_data(page, per_page, posts)

        resp_data     = posts_array_response(post_array, current_user.profile)
        resp_status   = 1
        resp_message  = 'success'
        resp_errors   = ''
      else
        resp_data     = ''
        resp_status   = 0
        resp_message  = 'Error'
        resp_errors   = 'Post not found'
        paging_data   = ''
      end
    rescue Exception => e
      resp_data       = ''
      resp_status     = 0
      paging_data     = ''
      resp_message    = 'error'
      resp_errors     = e
    end
    resp_request_id   = data[:request_id]
    JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors, paging_data: paging_data)

  end

  def self.post_to_timeline_album(album, post, current_user)
    if album.present?
      post_attachments = post.post_attachments
      if post_attachments.present?
        post_attachments.each do |attachment|
          album_image                          = album.album_images.build
          album_image.attachment_url           = attachment.attachment_url
          album_image.thumbnail_url            = attachment.thumbnail_url
          album_image.post_attachment_id       = attachment.id
          album_image.post_id                  = post.id
          album_image.save
        end
      else
        album_image                          = album.album_images.build
        album_image.post_id                  = post.id
        album_image.save
      end
    end
  end

  def self.timeline_posts_array_response(posts, profile, current_user)
    @@current_profile = profile
    posts = posts.as_json(
        only: [:id, :post_title, :post_description, :datetime, :is_post_public, :is_deleted, :created_at, :updated_at, :post_type],
        methods: [:likes_count,  :liked_by_me],
        include: {
            recent_post_likes: {
                only: [:id, :created_at, :updated_at],
                include: {
                    member_profile: {
                        only: [:id, :photo],
                        include: {
                            user: {
                                only: [:id, :email, :first_name, :last_name, :banner_image_1, :banner_image_2, :banner_image_3],
                                include:{
                                    # role: {
                                    #     only:[:id, :name]
                                    # }
                                }
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
                                only: [:id, :first_name, :last_name],
                                include:{
                                    # role: {
                                    #     only:[:id, :name]
                                    # }
                                }
                            }
                        }
                    }
                }
            },
            post_attachments: {
                only: [:id, :attachment_url, :thumbnail_url, :created_at, :updated_at, :attachment_type],
                include:{
                    post_photo_users:{
                        only:[:id, :member_profile_id, :post_attachment_id],
                        include: {
                            member_profile: {
                                only: [:id],
                                include: {
                                    user: {
                                        only: [:id, :first_name, :last_name]
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    )

    is_following = MemberProfile.is_following(profile, current_user)
    member_profile = profile.as_json(
        only: [:id, :about, :phone, :photo, :country_id, :state_id, :city_id, :gender, :dob, :height, :weight, :school],
        include: {
            user: {
                only: [:id, :first_name, :last_name, :banner_image_1, :banner_image_2, :banner_image_3],
                include:{
                    # role: {
                    #     only:[:id, :name]
                    # }
                }
            }
        }
    ).merge!(is_im_following: is_following)
    {posts: posts, member_profile: member_profile}.as_json
  end

  def self.discover(data, current_user)
    begin
      data = data.with_indifferent_access

      per_page = (data[:per_page] || @@limit).to_i
      page = (data[:page] || 1).to_i

    if data[:search][:key].present?
      search_key = data[:search][:key]

      posts     = Post.search_by_title(search_key)
      users     = User.search_by_title(search_key)
      hash_tags = Hashtag.search_by_title(search_key)
      if posts.present? || users.present? || hash_tags.present?
        paging_data, resp_data = discover_search_new(posts, users, hash_tags, page, per_page, data[:search][:type], current_user)
        resp_status = 1
        resp_message = 'Discover list'
        resp_errors = ''
      else
        resp_data    = ''
        resp_status  = 0
        resp_message = 'error'
        resp_errors  = 'No Record found'
        paging_data  = ''
      end
    else
      resp_data    = ''
      resp_status  = 0
      resp_message = 'error'
      resp_errors  = 'No Key found'
      paging_data  = ''
    end
    rescue Exception => e
      resp_data       = ''
      resp_status     = 0
      paging_data     = ''
      resp_message    = 'error'
      resp_errors     = e
    end
    resp_request_id   = data[:request_id]
    JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors, paging_data: paging_data)
  end

  def self.discover_search_new(posts, users, hash_tags, page, per_page, type, current_user)
    larger_array_type = ''

    if type.blank? || type == 'Member'
      profile_ids     = users.pluck(:profile_id)
      member_profiles = MemberProfile.where(id: profile_ids)
      member_profiles = member_profiles.page(page.to_i).per_page(per_page.to_i)
    end

    if type.blank? || type == 'Post'
      posts = posts.page(page.to_i).per_page(per_page.to_i)
    end

    if type.blank? || type == 'Hashtag'
      hash_tags = hash_tags.page(page.to_i).per_page(per_page.to_i)
    end

    if type.present?
      larger_array_type = type
    else
      if member_profiles.count > posts.count || member_profiles.count > hash_tags.count
        larger_array_type = 'Member'
      elsif posts.count > member_profiles.count || posts.count > hash_tags.count
        larger_array_type = 'Post'
      elsif hash_tags.count > member_profiles.count || hash_tags.count > posts.count
        larger_array_type = 'Hashtag'
      end
    end

    paging_data = JsonBuilder.get_paging_data(page, per_page, paging_records(member_profiles, posts, hash_tags, larger_array_type))
    resp_data = trending_api_loop_response(posts, hash_tags, true, current_user, member_profiles)
    [paging_data, resp_data]
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

  def self.trending_api_loop_response(posts, hash_tags, status, current_user, member_profiles=nil)
    @@current_profile = current_user.profile
    resp_array = []
    posts_array = []
    hash_tags_array = []
    profiles_array = []
    posts && posts.each do |post|
      member_profile   = post.member_profile
      post_attachments = post.post_attachments.as_json(
          only: [:id, :attachment_url, :thumbnail_url, :attachment_type],
          include:{
              post_photo_users: {
                  only: [:id],
                  include:{
                      member_profile:{
                          only:[:id],
                          include:{
                              user:{
                                  only: [:id, :first_name, :last_name]
                              }
                          }
                      }
                  }
              }
          }
      )
      posts_array << {
          type: "Post",
          id: post.id,
          post_title: post.post_title,
          post_description: post.post_description,
          is_post_public: post.is_post_public,
          post_type: post.post_type,
          likes_count: post.post_likes.count,
          comments_count: post.post_comments.count,
          post_members_counts: post.post_members.count,
          liked_by_me: post.liked_by_me,
          count: post.post_likes.where(like_status: true, is_deleted: false).count + post.post_comments.where(is_deleted: false).count,
          member_profile: {
              id: member_profile.id,
              photo: member_profile.photo,
              gender: member_profile.gender,
              user: {
                  id: member_profile.user.id,
                  first_name: member_profile.user.first_name,
                  last_name: member_profile.user.last_name
              }
          },
          post_attachments:  post_attachments
      }
    end

    # Hashtag
    hash_tags && hash_tags.each do |hash_tag|
      hash_tags_array << {
          type: "HashTag",
          id: hash_tag.id,
          name: hash_tag.name,
          count: hash_tag.count
      }
    end

    if status.present?
      member_profiles && member_profiles.each do |profile|
        profiles_array << {
            type: "MemberProfile",
            id: profile.id,
            photo: profile.photo,
            user: {
                id: profile.user.id,
                first_name: profile.user.first_name,
                last_name: profile.user.last_name,
            }
        }
      end
      resp_array << profiles_array
      resp_array << posts_array
      resp_array << hash_tags_array
      response = resp_array.flatten
      {dicsover_list: response}.as_json
    else
      resp_array << posts_array.take(5)
      resp_array << hash_tags_array.take(2)
      response = resp_array.flatten.sort_by { |hsh| hsh[:count] }.reverse
      {trending_list: response}.as_json
    end
  end

  def self.other_member_profile_posts_response(posts, profile)
    @@current_profile = profile
    posts = posts.as_json(
        only: [:id, :post_title, :post_description, :datetime, :is_post_public, :is_deleted, :created_at, :updated_at, :post_type, :location, :latitude, :longitude],
        methods: [:likes_count, :comments_count, :liked_by_me],
        include: {
            member_profile: {
                only: [:id, :about, :phone, :photo, :country_id, :is_profile_public, :gender],
                include: {
                    user: {
                        only: [:id, :first_name, :last_name]
                    }
                }
            },
            post_attachments: {
                only: [:id, :attachment_url, :thumbnail_url, :created_at, :updated_at, :attachment_type],
                include:{
                    post_photo_users:{
                        only:[:id, :member_profile_id],
                        include: {
                            member_profile: {
                                only: [:id],
                                include: {
                                    user: {
                                        only: [:id, :first_name, :last_name]
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    )
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

