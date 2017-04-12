class AddWinningPostIdToEvents < ActiveRecord::Migration[5.0]
  def change
    add_column :events, :post_id, :uuid
  end
end
