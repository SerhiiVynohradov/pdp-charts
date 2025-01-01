class CreateItems < ActiveRecord::Migration[7.2]
  def change
    create_table :items do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.string :category
      t.integer :progress, default: 0
      t.integer :position

      t.timestamps
    end
  end
end
