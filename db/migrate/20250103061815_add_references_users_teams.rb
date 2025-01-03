class AddReferencesUsersTeams < ActiveRecord::Migration[7.2]
  def change
    add_reference :users, :team, foreign_key: true, null: true
  end
end
