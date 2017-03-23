class CreateMemberFollowings < ActiveRecord::Migration[5.0]
  def change
    enable_extension 'uuid-ossp' unless extension_enabled?('uuid-ossp')
    create_table :member_followings  , id: :uuid, default: 'uuid_generate_v4()' do |t|
      t.uuid   :member_profile_id
      t.uuid   :following_profile_id
      t.string :following_status, default: 'pending'
      t.boolean :is_deleted, default: false

      t.timestamps
    end
  end
end
