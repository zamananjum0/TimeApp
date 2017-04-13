class AddWinningProfileIdToEvents < ActiveRecord::Migration[5.0]
  def change
    add_column :events, :winner_profile_id, :uuid
  end
end
