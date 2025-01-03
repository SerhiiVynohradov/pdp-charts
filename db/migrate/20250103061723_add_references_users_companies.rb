class AddReferencesUsersCompanies < ActiveRecord::Migration[7.2]
  def change
    add_reference :users, :company, foreign_key: true, null: true
  end
end
