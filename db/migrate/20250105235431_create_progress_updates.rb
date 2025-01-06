class CreateProgressUpdates < ActiveRecord::Migration[7.2]
  def change
    create_table :progress_updates do |t|
      t.references :item, null: false, foreign_key: true
      t.references :item_progress_column, null: false, foreign_key: true
      t.integer :percent

      t.timestamps
    end
  end
end
