class AddHashTagFieldToEvents < ActiveRecord::Migration[5.0]
  def change
    add_column :events, :hash_tag, :string
  end
end
