class CreateUserAlbums < ActiveRecord::Migration[5.0]
  def change
    create_table :user_albums do |t|
      t.integer :user_id
      t.string :name
      t.boolean :status
      t.integer  :member_profile_id
      t.string   :album_photo_url
      t.boolean  :default_album,     default: false
      t.timestamps
    end
  end
end
