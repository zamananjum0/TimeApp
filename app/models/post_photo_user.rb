class PostPhotoUser < ApplicationRecord
  belongs_to :post_attachment
  belongs_to :member_profile

end
