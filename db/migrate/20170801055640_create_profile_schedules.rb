class CreateProfileSchedules < ActiveRecord::Migration[5.0]
  def change
    enable_extension 'uuid-ossp' unless extension_enabled?('uuid-ossp')
    create_table :profile_schedules , id: :uuid, default: 'uuid_generate_v4()' do |t|
      t.datetime :available_start_time
      t.datetime :available_end_time
      t.uuid   :member_profile_id
      t.string :day

      t.timestamps
    end
  end
end
