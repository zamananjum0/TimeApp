class Event < ApplicationRecord
  include JsonBuilder
  include PgSearch
  
  @@limit           = 10
  @@current_profile = nil
  
  has_many :posts
  has_many :hashtags, through: :media_tags
  has_many :media_tags, as: :media, dependent: :destroy
  belongs_to :post   #this only for wiining post
  
  after_commit :process_hashtags
  pg_search_scope :search_by_title,
    against: :description,
    using: {
        tsearch: {
            any_word: true,
            dictionary: "english"
        }
    }
  
  def self.define_ranking
    # events  = Event.where('end_date > ? AND end_date < ?', DateTime.now.beginning_of_day, DateTime.now).order('end_date DESC')
    events  = Event.where('end_date < ?', DateTime.now).order('end_date DESC')
    events && events.each do |event|
      post =  Post.joins(:likes).select("posts.*, COUNT('likes.id') likes_count").where(likes: {likable_type: 'Post', is_like: true}, event_id: event.id).group('posts.id').order('likes_count DESC').try(:first)
      if post.present?
        event.post_id  = post.id
        event.member_profile_id = post.member_profile_id
        event.save!
      end
    end
  end
  
  def post_count
    self.posts.count
  end

  def process_hashtags
    arr = []
    hashtag_regex = /\B#\w\w+/
    text_hashtags_title = description.scan(hashtag_regex) if description.present?
    arr << text_hashtags_title
    tags = (arr.flatten).uniq
    ids = []
   
    tags&.each do |ar|
      tag = Hashtag.where("lower(name) = ?", ar.downcase).first
      if tag.present?
        tag.count = tag.count + 1
        tag.save!
      else
        tag = Hashtag.create!(name: ar.downcase)
      end
      media_tag = MediaTag.find_by_media_id_and_media_type_and_hashtag_id(self.id, AppConstants::EVENT, tag.id)
      if media_tag.blank?
        MediaTag.create!(media_id: self.id, media_type: AppConstants::EVENT, hashtag_id: tag.id)
      end
      ids << tag.id
    end
    MediaTag.where("media_id = ? AND hashtag_id NOT IN(?)", self.id, ids).try(:destroy_all)
  end
  
  def self.event_create(data, current_user)
    begin
      data    = data.with_indifferent_access
      profile = current_user.profile
      event   = profile.events.build(data[:event])
      if event.save
        resp_data       = {}
        resp_status     = 1
        resp_message    = 'Event Created'
        resp_errors     = ''
      else
        resp_data       = {}
        resp_status     = 0
        resp_message    = 'Errors'
        resp_errors     = event.errors.messages
      end
    rescue Exception => e
      resp_data       = {}
      resp_status     = 0
      paging_data     = ''
      resp_message    = 'error'
      resp_errors     = e
    end
    resp_request_id = data[:request_id]
    JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
  end

  def self.show_event(data, current_user)
    begin
      data  = data.with_indifferent_access
      event = Event.find_by_id(data[:id])
      resp_data       = event_response(event)
      resp_status     = 1
      resp_message    = 'Event details'
      resp_errors     = ''
    rescue Exception => e
      resp_data       = {}
      resp_status     = 0
      paging_data     = ''
      resp_message    = 'error'
      resp_errors     = e
    end
    resp_request_id   = data[:request_id]
    JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
  end
  
  def self.event_list(data, current_user)
    begin
      data = data.with_indifferent_access
      max_event_date = data[:max_event_date] || DateTime.now
      min_event_date = data[:min_event_date] || DateTime.now
      
      events      = Event.all
      if data[:start_date].present? && data[:end_date].present?
        events    = Event.where('start_date >= ? AND end_date <= ? AND is_deleted = false', data[:start_date], data[:end_date])
      end
      
      if data[:search_key].present?
        events  = events.where("lower(name) like ? ", "%#{data[:search_key]}%".downcase)
      end

      if data[:max_event_date].present?
        events = events.where("created_at > ?", max_event_date)
      elsif data[:min_event_date].present?
        events = events.where("created_at < ?", min_event_date)
      end
      events = events.order("created_at DESC")
      events = events.limit(@@limit)

      if events.present?
        Event.where("created_at > ?", events.first.created_at).present? ? previous_page_exist = true : previous_page_exist = false
        Event.where("created_at < ?", events.last.created_at).present? ? next_page_exist = true : next_page_exist = false
      end
      
      paging_data = {next_page_exist: next_page_exist, previous_page_exist: previous_page_exist}
      resp_data       = events_response(events)
      resp_status     = 1
      resp_message    = 'Event List'
      resp_errors     = ''
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
  
  def self.global_winners(data, current_user)
    begin
      data = data.with_indifferent_access
      max_event_date = data[:max_event_date] || DateTime.now
      min_event_date = data[:min_event_date] || DateTime.now
      
      if data[:max_event_date].present?
        events  = Event.where('end_date > ? AND end_date < ? AND is_deleted = false', max_event_date, DateTime.now)
      elsif data[:min_event_date].present?
        events  = Event.where('end_date < ? AND is_deleted = false', min_event_date)
      else
        events  = Event.where('end_date < ? AND is_deleted = false', DateTime.now)
      end
      events = events.where('post_id IS NOT NULL')
      
      # posts = []
      # last_event_date  = ''
      # events && events.each do |event|
      #   posts << Post.joins(:likes).select("posts.*, COUNT('likes.id') likes_count").where(likes: {likable_type: 'Post', is_like: true}, event_id: event.id).group('posts.id').order('likes_count DESC').try(:first)
      #   if posts.count >= 10
      #     break
      #   end
      #   last_event_date = event.end_date
      # end

      events = events.order("end_date DESC")
      events = events.limit(@@limit)

      if events.present?
        Event.where("end_date > ? AND end_date < ?", events.first.end_date, DateTime.now).present? ? previous_page_exist = true : previous_page_exist = false
        Event.where("end_date < ?", events.last.end_date).present? ? next_page_exist = true : next_page_exist = false
      end

      paging_data = {next_page_exist: next_page_exist, previous_page_exist: previous_page_exist}
      resp_data   = winners_response(events)
     
      resp_status = 1
      resp_message = 'Event list'
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

  def self.leader_winners(data, current_user)
    begin
      data = data.with_indifferent_access
      max_event_date = data[:max_event_date] || DateTime.now
      min_event_date = data[:min_event_date] || DateTime.now

      if data[:max_event_date].present?
        events  = Event.where('end_date > ? AND end_date < ?', max_event_date, DateTime.now)
      elsif data[:min_event_date].present?
        events  = Event.where('end_date < ?', min_event_date)
      else
        events  = Event.where('end_date < ?', DateTime.now)
      end
      events = events.where('post_id IS NOT NULL')

      following_ids = current_user.profile.member_followings.where(following_status: AppConstants::ACCEPTED, is_deleted: false).pluck(:following_profile_id)
      events = events.where(member_profile_id: following_ids)

      events = events.order("end_date DESC")
      events = events.limit(@@limit)

      if events.present?
        Event.where("end_date > ? AND end_date < ?", events.first.end_date, DateTime.now).present? ? previous_page_exist = true : previous_page_exist = false
        Event.where("end_date < ? AND member_profile_id IN (?)", events.last.end_date, following_ids).present? ? next_page_exist = true : next_page_exist = false
      end

      paging_data = {next_page_exist: next_page_exist, previous_page_exist: previous_page_exist}
      resp_data   = winners_response(events)
      resp_status = 1
      resp_message = 'Event list'
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
  # def self.leader_winners_new(data, current_user)
  #   begin
  #     data = data.with_indifferent_access
  #     per_page     = (data[:per_page] || @@limit).to_i
  #     page         = (data[:page] || 1).to_i
  #
  #     profile = current_user.profile
  #     groups  = profile.groups
  #     records = []
  #
  #     groups      = groups.page(page.to_i).per_page(per_page.to_i)
  #     paging_data = JsonBuilder.get_paging_data(page, per_page, groups)
  #
  #     groups && groups.each do |group|
  #       group_members = group.group_members
  #       if group_members.present?
  #         group_member_ids = group_members.pluck(:member_profile_id)
  #         member_profile = MemberProfile.joins(:events).select("member_profiles.*, COUNT('events.id') event_count").where(id: group_member_ids).group('member_profiles.id').order('event_count DESC').try(:first)
  #
  #         if member_profile.present?
  #           user = member_profile.user
  #           records << {
  #               id:   group.id,
  #               name: group.name,
  #               grou_members:[
  #                   {
  #                     id: group_members.where(member_profile_id: member_profile.id).try(:first).id,
  #                     member_profile:{
  #                         id:    member_profile.id,
  #                         photo: member_profile.photo,
  #                         user:{
  #                             id:       user.id,
  #                             username: user.username,
  #                             email:    user.email
  #                         }
  #                     }
  #                   }
  #               ]
  #           }
  #         end
  #       end
  #     end
  #     resp_data   = {groups: records}.as_json
  #     resp_status = 1
  #     resp_message = 'Group list'
  #     resp_errors = ''
  #   rescue Exception => e
  #     resp_data       = {}
  #     resp_status     = 0
  #     paging_data     = ''
  #     resp_message    = 'error'
  #     resp_errors     = e
  #   end
  #   resp_request_id   = data[:request_id]
  #   JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors, paging_data: paging_data)
  # end
  
  def self.competitions(data, current_user)
    begin
      data = data.with_indifferent_access
      per_page = (data[:per_page] || @@limit).to_i
      page     = (data[:page] || 1).to_i
      
      profile = current_user.profile
      event_ids = profile.posts.pluck(:event_id).try(:uniq)
      events = Event.where(id: event_ids)
      
      events = events.page(page.to_i).per_page(per_page.to_i)
      paging_data = JsonBuilder.get_paging_data(page, per_page, events)
      resp_data   = events_response(events)
      resp_status = 1
      resp_message = 'Group list'
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
  
  def self.events_response(events)
    events = events.as_json(
        only:    [:id, :name, :location, :description, :start_date, :end_date, :created_at, :updated_at, :is_deleted],
        methods: [:post_count],
        include:{
            media_tags:{
                only:[:id, :name]
            }
        }
    )
    { events: events }.as_json
  end

  def self.event_response(event)
    event = event.as_json(
        only:[:id, :name, :location, :start_date, :end_date, :is_deleted, :hash_tag, :description],
        include:{
            media_tags:{
                only:[:id, :name]
            }
        }
    )

    events_array = []
    events_array << event

    { events: events_array }.as_json
  end

  def self.winners_response(events)
    events = events.as_json(
        only:    [:id, :name, :location, :start_date, :end_date, :description],
        include:{
            hashtags:{
                only:[:id, :name]
            },
            post:{
                only:[:id, :post_title],
                methods: [:likes_count],
                include:{
                    post_attachments: {
                        only: [:attachment_url, :thumbnail_url, :attachment_type, :width, :height]
                    },
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
  
    { events: events }.as_json
  end
end