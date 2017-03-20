class PostUser < ApplicationRecord
  belongs_to :post
  belongs_to :member_profile
end
