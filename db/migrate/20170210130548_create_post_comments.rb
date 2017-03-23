class CreatePostComments < ActiveRecord::Migration[5.0]
  def change
    enable_extension 'uuid-ossp' unless extension_enabled?('uuid-ossp')
    create_table :post_comments  , id: :uuid, default: 'uuid_generate_v4()' do |t|
      t.uuid  :post_id
      t.uuid  :member_profile_id
      t.text     :post_comment
      t.boolean  :is_deleted ,        default: false

      t.timestamps
    end
  end
end
