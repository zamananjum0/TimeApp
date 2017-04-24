class CreateGroups < ActiveRecord::Migration[5.0]
  def change
    enable_extension 'uuid-ossp' unless extension_enabled?('uuid-ossp')
    create_table :groups, id: :uuid, default: 'uuid_generate_v4()' do |t|
      t.string :name

      t.timestamps
    end
  end
end
