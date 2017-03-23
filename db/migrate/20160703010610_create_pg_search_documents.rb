class CreatePgSearchDocuments < ActiveRecord::Migration
  def self.up
    say_with_time("Creating table for pg_search multisearch") do
      enable_extension 'uuid-ossp' unless extension_enabled?('uuid-ossp')
      create_table :pg_search_documents , id: :uuid, default: 'uuid_generate_v4()' do |t|
        t.text :content
        t.belongs_to :searchable, polymorphic: true, index: true
        t.timestamps null: false
      end
    end
  end

  def self.down
    say_with_time("Dropping table for pg_search multisearch") do
      drop_table :pg_search_documents
    end
  end
end
