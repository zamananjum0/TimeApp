class Group < ApplicationRecord
  include JsonBuilder
  
  belongs_to :member_profile
  has_many :group_members
  
  validates_uniqueness_of :name, :scope => :member_profile_id
  accepts_nested_attributes_for :group_members
  
  
  def self.group_list(data, current_user)
  begin
    data  = data.with_indifferent_access
    per_page     = (data[:per_page] || @@limit).to_i
    page         = (data[:page] || 1).to_i
    
    groups = current_user.profile.groups
    groups      = groups.page(page.to_i).per_page(per_page.to_i)
    paging_data = JsonBuilder.get_paging_data(page, per_page, groups)
    resp_data   = groups_response(groups)
    resp_status = 1
    resp_message = 'group list'
    resp_errors  = ''
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

  def self.create_group(data, current_user)
    begin
      data  = data.with_indifferent_access
      group = current_user.profile.groups.build(data[:group])
      if group.save
        resp_data       = {}
        resp_status     = 1
        resp_message    = 'Group Created'
        resp_errors     = ''
      else
        resp_data       = {}
        resp_status     = 0
        resp_message    = 'Errors'
        resp_errors     = group.errors.messages
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
  
  def self.update_group(data, current_user)
  begin
    data  = data.with_indifferent_access
    profile = current_user.profile
    group   = profile.groups.find_by_id(data[:group][:id])
    if group.present?
      if data[:group_members].present?
        existing_group_members = group.group_members
        group_members = data[:group_members]
        existing_group_members.each do |group_member|
          if !group_members.include? group_member.member_profile_id
            group_member.destroy
          end
        end
  
        if group_members.count != group.group_members.count
          existing_group_members = group.group_members.pluck(:member_profile_id)
          group_members.each do |member_id|
            if !existing_group_members.include? member_id
              grp = group.group_members.build(member_profile_id: member_id)
              grp.save!
            end
          end
        end
      end
      # group.name = data[:group][:name]
      if data[:group][:name].present?
        if !profile.groups.where('lower(name) = ?', data[:group][:name].downcase).present?
          group.name = data[:group][:name]
          group.save!(vaidate: false)
        end
      end
      resp_data       = {}
      resp_status     = 1
      resp_message    = 'Group Uupdated'
      resp_errors     = ''
      
    else
      resp_data       = {}
      resp_status     = 0
      resp_message    = 'Errors'
      resp_errors     = 'Group not found'
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
  
  def self.groups_response(groups)
    groups = groups.as_json(
     only:[:id, :name],
     include:{
         group_members:{
             only:[:id],
             include:{
                 member_profile:{
                     only:[:id, :photo],
                     include:{
                         user:{
                             only:[:id, :username, :email]
                         }
                     }
                 }
             }
         }
     }
    )
    
    {groups: groups}.as_json
  end
end
