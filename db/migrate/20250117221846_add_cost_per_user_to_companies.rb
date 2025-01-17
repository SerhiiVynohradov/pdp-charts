class AddCostPerUserToCompanies < ActiveRecord::Migration[7.2]
  def change
    add_column :companies, :cost_per_user, :float, default: 0.0
  end
end
