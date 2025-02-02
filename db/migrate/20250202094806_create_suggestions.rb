class CreateSuggestions < ActiveRecord::Migration[7.2]
  def change
    create_table :suggestions do |t|
      t.string :title
      t.text :description
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
