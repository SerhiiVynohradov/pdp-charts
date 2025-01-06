class CreateItemProgressColumns < ActiveRecord::Migration[7.2]
  def change
    create_table :item_progress_columns do |t|
      t.references :user, null: false, foreign_key: true
      t.date :date

      t.timestamps
    end
  end
end
