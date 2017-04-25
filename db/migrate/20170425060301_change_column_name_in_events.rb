class ChangeColumnNameInEvents < ActiveRecord::Migration[5.0]
  def change
    rename_column :events, :winner_profile_id, :member_profile_id
  end
end
