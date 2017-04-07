class AddIsDeletedToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :is_deleted, :boolean, default: false
  end
end
