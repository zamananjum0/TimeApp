class MediaTag < ApplicationRecord
  belongs_to :media, polymorphic: true
  belongs_to :hashtag
end
