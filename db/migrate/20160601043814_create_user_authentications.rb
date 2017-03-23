class CreateUserAuthentications < ActiveRecord::Migration[5.0]
  def change
    enable_extension 'uuid-ossp' unless extension_enabled?('uuid-ossp')
    create_table :user_authentications , id: :uuid, default: 'uuid_generate_v4()' do |t|
      t.uuid :user_id
      t.string :social_site_id
      t.string :social_site
      t.string :profile_image_url

      t.timestamps
    end
  end
end
