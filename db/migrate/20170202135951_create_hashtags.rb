class CreateHashtags < ActiveRecord::Migration[5.0]
  def change
    enable_extension 'uuid-ossp' unless extension_enabled?('uuid-ossp')
    create_table :hashtags  , id: :uuid, default: 'uuid_generate_v4()' do |t|
      t.string :name
      t.integer :count, default: 0

      t.timestamps
    end
  end
end
