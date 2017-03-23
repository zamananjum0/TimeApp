class CreatePosts < ActiveRecord::Migration[5.0]
  def change
    enable_extension 'uuid-ossp' unless extension_enabled?('uuid-ossp')
    create_table :posts  , id: :uuid, default: 'uuid_generate_v4()' do |t|
      t.uuid     :member_profile_id
      t.string   :post_title
      t.datetime :post_datetime
      t.text     :post_description
      t.boolean  :is_post_public
      t.boolean  :is_deleted, default: false
      t.string   :post_type
      t.timestamps
    end
  end
end
