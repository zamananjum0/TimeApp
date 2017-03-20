class CreatePostPhotoUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :post_photo_users do |t|
      t.integer  :post_attachment_id
      t.integer :member_profile_id

      t.timestamps
    end
  end
end
