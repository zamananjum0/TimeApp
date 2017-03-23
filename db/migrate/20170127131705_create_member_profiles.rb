class CreateMemberProfiles < ActiveRecord::Migration[5.0]
  def change
    enable_extension 'uuid-ossp' unless extension_enabled?('uuid-ossp')
    create_table :member_profiles , id: :uuid, default: 'uuid_generate_v4()' do |t|
      t.string   :photo, default: 'http://bit.ly/25CCXzq'
      t.datetime :available_start_time
      t.datetime :available_end_time
      t.integer  :remaining_posts_count
      t.timestamps
    end
  end
end
