class AddMemberIdToGroups < ActiveRecord::Migration[5.0]
  def change
    add_column :groups, :member_profile_id, :uuid
  end
end
