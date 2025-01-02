class CreateItems < ActiveRecord::Migration[7.2]
  def change
    create_table :items do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.string :description
      t.string :link
      t.string :reason
      t.string :category
      t.string :status
      t.string :expected_results
      t.integer :progress, default: 0
      t.integer :effort, default: 1
      t.string :result
      t.string :certificate_link
      t.integer :position

      t.timestamps
    end
  end
end
