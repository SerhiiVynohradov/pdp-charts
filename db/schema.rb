# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2025_01_17_205058) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "companies", force: :cascade do |t|
    t.string "name"
    t.boolean "charts_visible", default: false
    t.boolean "status", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "invoices", force: :cascade do |t|
    t.string "invoiceable_type"
    t.bigint "invoiceable_id"
    t.string "number"
    t.decimal "amount", precision: 10, scale: 2
    t.string "currency", default: "USD"
    t.date "issue_date"
    t.date "due_date"
    t.string "status", default: "unpaid"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invoiceable_type", "invoiceable_id"], name: "index_invoices_on_invoiceable"
  end

  create_table "item_progress_columns", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.date "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_item_progress_columns_on_user_id"
  end

  create_table "items", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.string "description"
    t.string "link"
    t.string "reason"
    t.string "category"
    t.boolean "status", default: true
    t.string "expected_results"
    t.integer "progress", default: 0
    t.integer "effort", default: 1
    t.string "result"
    t.string "certificate_link"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "category_id"
    t.index ["category_id"], name: "index_items_on_category_id"
    t.index ["user_id"], name: "index_items_on_user_id"
  end

  create_table "progress_updates", force: :cascade do |t|
    t.bigint "item_id", null: false
    t.bigint "item_progress_column_id", null: false
    t.integer "percent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_progress_updates_on_item_id"
    t.index ["item_progress_column_id"], name: "index_progress_updates_on_item_progress_column_id"
  end

  create_table "recommended_items", force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.string "link"
    t.string "expected_results"
    t.integer "effort", default: 1
    t.bigint "team_id"
    t.bigint "company_id"
    t.bigint "category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_recommended_items_on_category_id"
    t.index ["company_id"], name: "index_recommended_items_on_company_id"
    t.index ["team_id"], name: "index_recommended_items_on_team_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "name"
    t.boolean "charts_visible", default: false
    t.boolean "status", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "company_id"
    t.index ["company_id"], name: "index_teams_on_company_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "role", default: 0, null: false
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "company_id"
    t.bigint "team_id"
    t.index ["company_id"], name: "index_users_on_company_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["team_id"], name: "index_users_on_team_id"
  end

  add_foreign_key "item_progress_columns", "users"
  add_foreign_key "items", "categories"
  add_foreign_key "items", "users"
  add_foreign_key "progress_updates", "item_progress_columns"
  add_foreign_key "progress_updates", "items"
  add_foreign_key "teams", "companies"
  add_foreign_key "users", "companies"
  add_foreign_key "users", "teams"
end
