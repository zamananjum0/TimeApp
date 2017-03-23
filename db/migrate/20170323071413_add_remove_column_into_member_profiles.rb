class AddRemoveColumnIntoMemberProfiles < ActiveRecord::Migration[5.0]
  def change
    remove_column :member_profiles, :remaining_posts_count
    add_column    :member_profiles, :remaining_posts_count, :integer, default: 10
  end
end
