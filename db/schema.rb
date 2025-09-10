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

ActiveRecord::Schema[7.1].define(version: 2025_09_10_072631) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "vector"

  create_table "benchmark_results", force: :cascade do |t|
    t.string "query", null: false
    t.text "answer", null: false
    t.string "llm_model", null: false
    t.string "embedding_model", null: false
    t.integer "chunk_size"
    t.integer "overlap"
    t.integer "limit"
    t.integer "top_chunks"
    t.integer "response_time_ms"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "chat_feedbacks", force: :cascade do |t|
    t.string "chat_id"
    t.bigint "chat_message_id", null: false
    t.boolean "liked"
    t.string "llm_model"
    t.string "embedding_model"
    t.integer "chunk_size"
    t.integer "overlap"
    t.integer "limit"
    t.integer "top_chunks"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chat_message_id"], name: "index_chat_feedbacks_on_chat_message_id"
  end

  create_table "chat_messages", force: :cascade do |t|
    t.integer "role", null: false
    t.text "content", null: false
    t.jsonb "sources", default: []
    t.jsonb "snippets", default: []
    t.string "chat_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", default: 0, null: false
    t.integer "response_time_ms"
  end

  add_foreign_key "chat_feedbacks", "chat_messages"
end
