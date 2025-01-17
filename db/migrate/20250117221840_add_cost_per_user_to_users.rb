class AddCostPerUserToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :cost_per_user, :float, default: 0.0
  end
end
