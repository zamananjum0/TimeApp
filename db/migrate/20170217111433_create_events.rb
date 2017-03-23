class CreateEvents < ActiveRecord::Migration[5.0]
  def change
    enable_extension 'uuid-ossp' unless extension_enabled?('uuid-ossp')
    create_table :events  , id: :uuid, default: 'uuid_generate_v4()' do |t|
      t.string   :name
      t.text     :location
      t.text     :description
      t.datetime :start_date
      t.datetime :end_date
     
      t.timestamps
    end
  end
end
