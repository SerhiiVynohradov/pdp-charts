class CreateEvents < ActiveRecord::Migration[7.2]
  def change
    create_table :events do |t|
      t.string :name
      t.date :date
      t.references :eventable, polymorphic: true, index: true

      t.timestamps
    end
  end
end
