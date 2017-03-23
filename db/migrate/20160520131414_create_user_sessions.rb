class CreateUserSessions < ActiveRecord::Migration[5.0]
  def change
    enable_extension 'uuid-ossp' unless extension_enabled?('uuid-ossp')
    create_table :user_sessions , id: :uuid, default: 'uuid_generate_v4()' do |t|
      t.uuid   :user_id
      t.string :device_type
      t.string :device_uuid
      t.string :auth_token
      t.string :session_status
      t.string :device_token

      t.timestamps
    end
  end
end
