class Event < ApplicationRecord
  include JsonBuilder
  include PgSearch
  
  @@limit           = 10
  @@current_profile = nil
  has_many   :posts
  
  pg_search_scope :search_by_title,
    against: :description,
    using: {
        tsearch: {
            any_word: true,
            dictionary: "english"
        }
    }

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

  def self.events_response(events)
    events = events.as_json(
        only:    [:id, :name, :location, :description, :start_date, :end_date]
    )

    { events: events }.as_json
  end

  def self.event_response(event)
    event = event.as_json(
        only:    [:id, :name, :country_id, :state_id, :city_id, :organization, :location, :description, :cost, :currency_id, :camp_website, :start_date, :end_date, :upload, :member_profile_id, :created_at, :updated_at]
    )

    events_array = []
    events_array << event

    { events: events_array }.as_json
  end


end