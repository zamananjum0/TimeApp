class CreateComments < ActiveRecord::Migration[5.0]
  def change
    enable_extension 'uuid-ossp' unless extension_enabled?('uuid-ossp')
    create_table :comments , id: :uuid, default: 'uuid_generate_v4()' do |t|
      t.uuid    :member_profile_id
      t.uuid    :commentable_id
      t.string  :commentable_type
      t.boolean :is_deleted, default: :false
      t.text    :comment
      
      t.timestamps
    end
  end
end
