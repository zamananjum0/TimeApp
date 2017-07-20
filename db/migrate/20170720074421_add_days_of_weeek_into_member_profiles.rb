class AddDaysOfWeeekIntoMemberProfiles < ActiveRecord::Migration[5.0]
  def change
    add_column :member_profiles, :days_of_the_week, :text, array: true, default: []
  end
end
