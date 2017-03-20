class MemberGroupContact < ApplicationRecord
  belongs_to :member_group
  belongs_to :member_profile

end
