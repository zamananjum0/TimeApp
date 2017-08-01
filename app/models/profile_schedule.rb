class ProfileSchedule < ApplicationRecord
  validates_uniqueness_of :day, scope: :member_profile_id
end
