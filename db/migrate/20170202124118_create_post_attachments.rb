class CreatePostAttachments < ActiveRecord::Migration[5.0]
  def change
    enable_extension 'uuid-ossp' unless extension_enabled?('uuid-ossp')
    create_table :post_attachments  , id: :uuid, default: 'uuid_generate_v4()' do |t|
      t.uuid   :post_id
      t.string :attachment_url
      t.string :thumbnail_url
      t.string  :attachment_type
      t.timestamps
    end
  end
end
