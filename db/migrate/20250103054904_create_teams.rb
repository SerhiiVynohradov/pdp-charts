class CreateTeams < ActiveRecord::Migration[7.2]
  def change
    create_table :teams do |t|
      t.string :name
      t.boolean :charts_visible, default: true
      t.boolean :status, default: true

      t.timestamps
    end
  end
end
