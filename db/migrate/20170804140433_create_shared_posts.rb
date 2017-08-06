class CreateSharedPosts < ActiveRecord::Migration[5.0]
  def change
    create_table :shared_posts do |t|
      t.uuid :post_id
      t.uuid :member_profile_id

      t.timestamps
    end
  end
end
