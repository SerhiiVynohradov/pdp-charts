class AddReferencesTeamsCompanies < ActiveRecord::Migration[7.2]
  def change
    add_reference :teams, :company, foreign_key: true, null: true
  end
end
