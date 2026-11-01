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

ActiveRecord::Schema[8.1].define(version: 2026_11_01_143159) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "audio_versions", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.integer "version_number"
    t.bigint "uploaded_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id", "version_number"], name: "index_audio_versions_on_project_id_and_version_number", unique: true
    t.index ["project_id"], name: "index_audio_versions_on_project_id"
    t.index ["uploaded_by_id"], name: "index_audio_versions_on_uploaded_by_id"
  end

  create_table "comments", force: :cascade do |t|
    t.bigint "audio_version_id", null: false
    t.bigint "user_id", null: false
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["audio_version_id"], name: "index_comments_on_audio_version_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "projects", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_projects_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "audio_versions", "projects"
  add_foreign_key "audio_versions", "users", column: "uploaded_by_id"
  add_foreign_key "comments", "audio_versions"
  add_foreign_key "comments", "users"
  add_foreign_key "projects", "users"
end
