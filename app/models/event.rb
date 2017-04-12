class Event < ApplicationRecord
  include JsonBuilder
  include PgSearch
  
  @@limit           = 10
  @@current_profile = nil
  has_many   :posts
  belongs_to :post   #this only for wiining post
  
  pg_search_scope :search_by_title,
    against: :description,
    using: {
        tsearch: {
            any_word: true,
            dictionary: "english"
        }
    }
  def post_count
    self.posts.count
  end
  
  def self.event_create(data, current_user)
    begin
      data    = data.with_indifferent_access
      profile = current_user.profile
      event   = profile.events.build(data[:event])
      if event.save
        resp_data       = ''
        resp_status     = 1
        resp_message    = 'Event Created'
        resp_errors     = ''
      else
        resp_data       = ''
        resp_status     = 0
        resp_message    = 'Errors'
        resp_errors     = event.errors.messages
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

  def self.show_event(data, current_user)
    begin
      data  = data.with_indifferent_access
      event = Event.find_by_id(data[:id])
      resp_data       = event_response(event)
      resp_status     = 1
      resp_message    = 'Event details'
      resp_errors     = ''
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
  
  def self.event_list(data, current_user)
    begin
      data = data.with_indifferent_access

      per_page    = (data[:per_page] || @@limit).to_i
      page        = (data[:page] || 1).to_i
      
      events      = Event.all
      if data[:start_date].present? && data[:end_date].present?
        events    = Event.where('start_date >= ? AND end_date <= ? AND is_deleted = false', data[:start_date], data[:end_date])
      end
      
      if data[:search_key].present?
        events  = events.where("lower(name) like ? ", "%#{data[:search_key]}%".downcase)
      end
      
      events      = events.order('created_at DESC')
      events      = events.page(page.to_i).per_page(per_page.to_i)
      paging_data = JsonBuilder.get_paging_data(page, per_page, events)

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
      max_event_date = data[:max_event_date] || Time.now
      min_event_date = data[:min_event_date] || Time.now
    
      if data[:max_event_date].present?
        events  = Event.where('end_date > ? AND end_date < ?', max_event_date, Time.now).order('end_date DESC')
      elsif data[:min_event_date].present?
        events  = Event.where('end_date < ?', min_event_date).order('end_date DESC')
      else
        events  = Event.where('end_date < ?', Date.today).order('end_date DESC')
      end
    
      if events.present?
        Event.where("end_date > ? AND end_date < ?", events.first.end_date, Time.now).present? ? previous_page_exist = true : previous_page_exist = false
        Event.where("end_date < ?", last_event_date).present? ? next_page_exist = true : next_page_exist = false
      end
    
      paging_data = {next_page_exist: next_page_exist, previous_page_exist: previous_page_exist}
    
      resp_data   = winners_response(posts)
      resp_status = 1
      resp_message = 'Post list'
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
        only:    [:id, :name, :location, :description, :start_date, :end_date],
        methods: [:post_count],
    )

    { events: events }.as_json
  end

  def self.event_response(event)
    event = event.as_json(
        only:    [:id, :name, :location, :start_date, :end_date, :is_deleted]
    )

    events_array = []
    events_array << event

    { events: events_array }.as_json
  end

  def self.winners_response(events)
    events = events.as_json(
        only:    [:id, :name, :location, :start_date, :end_date],
        include:{
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