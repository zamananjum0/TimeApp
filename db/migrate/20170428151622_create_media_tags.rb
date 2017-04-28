class CreateMediaTags < ActiveRecord::Migration[5.0]
  def change
    create_table :media_tags do |t|
      t.uuid :hashtag_id
      t.uuid :media_id
      t.string :media_type

      t.timestamps
    end
  end
end
