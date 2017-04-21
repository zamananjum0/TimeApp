class CreateEventTags < ActiveRecord::Migration[5.0]
  def change
    enable_extension 'uuid-ossp' unless extension_enabled?('uuid-ossp')
    create_table :event_tags, id: :uuid, default: 'uuid_generate_v4()' do |t|
      t.uuid :event_id
      t.uuid :hashtag_id

      t.timestamps
    end
  end
end
