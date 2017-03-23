class CreateSynchronizations < ActiveRecord::Migration[5.0]
  def change
    enable_extension 'uuid-ossp' unless extension_enabled?('uuid-ossp')
    create_table :synchronizations  , id: :uuid, default: 'uuid_generate_v4()' do |t|
      t.uuid     :member_profile_id
      t.string   :sync_token
      t.string   :sync_type
      t.datetime :synced_date

      t.timestamps
    end
  end
end
