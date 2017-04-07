class CreateAdminProfiles < ActiveRecord::Migration[5.0]
  def change
    enable_extension 'uuid-ossp' unless extension_enabled?('uuid-ossp')
    create_table :admin_profiles , id: :uuid, default: 'uuid_generate_v4()' do |t|
      t.string :photo
      t.string :about

      t.timestamps
    end
  end
end
