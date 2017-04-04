class CreateOpenSessions < ActiveRecord::Migration[5.0]
  def change
    create_table :open_sessions do |t|
      t.uuid :user_id
      t.string :session_id
      t.uuid :media_id
      t.string :media_type

      t.timestamps
    end
  end
end
