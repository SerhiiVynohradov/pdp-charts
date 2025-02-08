class AddLimitsToTeams < ActiveRecord::Migration[7.2]
  def change
    add_column :teams, :effort_line, :integer, default: 1000
    add_column :teams, :wa_line, :integer, default: 40
    add_column :teams, :items_line, :integer, default: 5
  end
end
