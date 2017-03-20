class PostAttachment < ApplicationRecord
  belongs_to :post
  has_many :post_photo_users, dependent: :destroy

  accepts_nested_attributes_for :post_photo_users
end
