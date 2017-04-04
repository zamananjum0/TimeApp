class CreateLikes < ActiveRecord::Migration[5.0]
  def change
    enable_extension 'uuid-ossp' unless extension_enabled?('uuid-ossp')
    create_table :likes , id: :uuid, default: 'uuid_generate_v4()' do |t|
      t.uuid    :member_profile_id
      t.uuid    :likable_id
      t.string  :likable_type
      t.boolean :is_like,    default:  true
      t.boolean :is_deleted, default:  false
      t.timestamps
    end
  end
end
