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

ActiveRecord::Schema[7.1].define(version: 2025_10_16_000002) do
  create_table "ai_scores", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "post_id", null: false
    t.integer "total_score", null: false
    t.integer "cause_analysis_score"
    t.integer "solution_specificity_score"
    t.integer "learning_articulation_score"
    t.integer "prevention_awareness_score"
    t.text "feedback_comment"
    t.string "suggested_category"
    t.string "model_version", default: "gpt-4-turbo"
    t.integer "tokens_used"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_ai_scores_on_created_at"
    t.index ["post_id"], name: "index_ai_scores_on_post_id"
    t.index ["total_score"], name: "index_ai_scores_on_total_score"
  end

  create_table "categories", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "color", default: "#6B7280"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_categories_on_name", unique: true
  end

  create_table "posts", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "category_id", null: false
    t.string "title", null: false
    t.text "content", null: false
    t.text "cause"
    t.text "solution"
    t.text "learning"
    t.date "occurred_at"
    t.boolean "ai_evaluated", default: false
    t.datetime "ai_evaluated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_posts_on_category_id"
    t.index ["created_at"], name: "index_posts_on_created_at"
    t.index ["occurred_at"], name: "index_posts_on_occurred_at"
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "reflection_items", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "reminder_id", null: false
    t.bigint "post_id", null: false
    t.text "content", null: false
    t.string "item_type"
    t.integer "position", default: 0, null: false
    t.boolean "checked", default: false, null: false
    t.datetime "checked_at"
    t.boolean "ai_generated", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["checked"], name: "index_reflection_items_on_checked"
    t.index ["post_id"], name: "index_reflection_items_on_post_id"
    t.index ["reminder_id", "position"], name: "index_reflection_items_on_reminder_id_and_position"
    t.index ["reminder_id"], name: "index_reflection_items_on_reminder_id"
  end

  create_table "reminders", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "post_id", null: false
    t.bigint "user_id", null: false
    t.string "reminder_type", null: false
    t.date "scheduled_date", null: false
    t.datetime "completed_at"
    t.string "status", default: "pending", null: false
    t.integer "checked_items_count", default: 0, null: false
    t.integer "total_items_count", default: 0, null: false
    t.integer "retry_count", default: 0, null: false
    t.text "ai_advice"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["post_id"], name: "index_reminders_on_post_id"
    t.index ["reminder_type"], name: "index_reminders_on_reminder_type"
    t.index ["scheduled_date", "status"], name: "index_reminders_on_scheduled_date_and_status"
    t.index ["user_id", "status"], name: "index_reminders_on_user_id_and_status"
    t.index ["user_id"], name: "index_reminders_on_user_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "name"
    t.string "mentor_personality", default: "balanced"
    t.boolean "reminder_enabled", default: false
    t.integer "reminder_interval_days", default: 7
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "ai_scores", "posts"
  add_foreign_key "posts", "categories"
  add_foreign_key "posts", "users"
  add_foreign_key "reflection_items", "posts"
  add_foreign_key "reflection_items", "reminders"
  add_foreign_key "reminders", "posts"
  add_foreign_key "reminders", "users"
end
