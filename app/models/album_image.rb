class AlbumImage < ApplicationRecord
  belongs_to :user_album
  belongs_to :post
end
