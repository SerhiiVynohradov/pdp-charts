class CreateRecommendedItems < ActiveRecord::Migration[7.2]
  def change
    create_table :recommended_items do |t|
      t.string  :name,             null: false
      t.string  :description
      t.string  :link
      t.string  :expected_results
      t.integer :effort,           default: 1
      t.bigint  :team_id
      t.bigint  :company_id
      t.bigint  :category_id

      t.timestamps
    end

    # Если нужно, можете добавить индексы и/или внешние ключи
    add_index :recommended_items, :team_id
    add_index :recommended_items, :company_id
    add_index :recommended_items, :category_id

    # опционально, если нужно каскадное удаление или связи:
    # add_foreign_key :recommended_items, :teams,    column: :team_id
    # add_foreign_key :recommended_items, :companies, column: :company_id
    # add_foreign_key :recommended_items, :categories, column: :category_id
  end
end
