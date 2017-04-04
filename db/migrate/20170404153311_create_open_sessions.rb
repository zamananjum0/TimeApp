class CreateOpenSessions < ActiveRecord::Migration[5.0]
  def change
    enable_extension 'uuid-ossp' unless extension_enabled?('uuid-ossp')
    create_table :open_sessions , id: :uuid, default: 'uuid_generate_v4()' do |t|
      t.uuid :user_id
      t.string :session_id
      t.uuid :media_id
      t.string :media_type

      t.timestamps
    end
  end
end
