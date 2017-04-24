class CreateGroupMembers < ActiveRecord::Migration[5.0]
  def change
    enable_extension 'uuid-ossp' unless extension_enabled?('uuid-ossp')
    create_table :group_members, id: :uuid, default: 'uuid_generate_v4()' do |t|
      t.uuid :group_id
      t.uuid :member_profile_id

      t.timestamps
    end
  end
end
