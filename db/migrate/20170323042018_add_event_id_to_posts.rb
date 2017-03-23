class AddEventIdToPosts < ActiveRecord::Migration[5.0]
  def change
    remove_column :posts, :is_post_public
    add_column    :posts, :event_id, :uuid
  end
end
