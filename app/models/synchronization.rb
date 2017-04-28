class Synchronization < ApplicationRecord
  belongs_to :member_profile

  @@limit =2


  def self.sync_response(profile, records, message)
    if message == "Posts"
      data  = Post.posts_array_response(records, profile)
    elsif message == "Member Followings"
      data = {
          members_followings: sync_members_followings_response(records)
      }
    elsif message == "Member Followers"
      data = {
          members_followers: sync_members_followings_response(records)
      }
    end
  end

  def self.sync_members_followings_response(member_followings)
    member_followings.as_json(
        only: [:id, :member_profile_id, :following_profile_id, :following_status, :created_at, :updated_at],
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
    )
  end

end
