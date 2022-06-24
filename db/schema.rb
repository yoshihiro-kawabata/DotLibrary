# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_06_17_065126) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "authorities", force: :cascade do |t|
    t.integer "level", null: false
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "books", force: :cascade do |t|
    t.string "name", null: false
    t.integer "number", null: false
    t.string "keyword1"
    t.string "keyword2"
    t.string "keyword3"
    t.string "keyword4"
    t.string "keyword5"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "books_providers", force: :cascade do |t|
    t.bigint "provider_id", null: false
    t.bigint "book_id", null: false
    t.integer "quantity", null: false
    t.boolean "hand_flg", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["book_id"], name: "index_books_providers_on_book_id"
    t.index ["provider_id"], name: "index_books_providers_on_provider_id"
  end

  create_table "books_stores", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "book_id", null: false
    t.integer "quantity", null: false
    t.integer "price", null: false
    t.text "limit", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["book_id"], name: "index_books_stores_on_book_id"
    t.index ["store_id"], name: "index_books_stores_on_store_id"
  end

  create_table "comments", force: :cascade do |t|
    t.string "user_name", null: false
    t.string "content"
    t.bigint "order_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["order_id"], name: "index_comments_on_order_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "details", force: :cascade do |t|
    t.string "name", null: false
    t.integer "quantity"
    t.integer "price"
    t.text "remark"
    t.bigint "order_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["order_id"], name: "index_details_on_order_id"
  end

  create_table "libraries", force: :cascade do |t|
    t.string "name", null: false
    t.integer "sub_number", null: false
    t.string "email", null: false
    t.string "phone", null: false
    t.string "address", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_libraries_on_user_id"
  end

  create_table "messages", force: :cascade do |t|
    t.text "content"
    t.text "create_name"
    t.bigint "create_id"
    t.text "user_name"
    t.bigint "user_id", null: false
    t.boolean "read_flg", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "orders", force: :cascade do |t|
    t.text "title"
    t.bigint "user_id", null: false
    t.string "user_name", null: false
    t.bigint "receive_user_id", null: false
    t.string "receive_user_name", null: false
    t.integer "number", null: false
    t.boolean "complete_flg", default: false, null: false
    t.text "ord_limit"
    t.text "condition"
    t.integer "price"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "providers", force: :cascade do |t|
    t.string "name", null: false
    t.integer "sub_number", null: false
    t.string "email", null: false
    t.string "phone", null: false
    t.string "address", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_providers_on_user_id"
  end

  create_table "stores", force: :cascade do |t|
    t.string "name", null: false
    t.integer "sub_number", null: false
    t.string "phone", null: false
    t.string "fax"
    t.string "manager"
    t.string "email", null: false
    t.string "address", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_stores_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.integer "number"
    t.string "password_digest"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "users_authorities", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "authority_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["authority_id"], name: "index_users_authorities_on_authority_id"
    t.index ["user_id"], name: "index_users_authorities_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "books_providers", "books"
  add_foreign_key "books_providers", "providers"
  add_foreign_key "books_stores", "books"
  add_foreign_key "books_stores", "stores"
  add_foreign_key "comments", "orders"
  add_foreign_key "comments", "users"
  add_foreign_key "details", "orders"
  add_foreign_key "libraries", "users"
  add_foreign_key "messages", "users"
  add_foreign_key "orders", "users"
  add_foreign_key "providers", "users"
  add_foreign_key "stores", "users"
  add_foreign_key "users_authorities", "authorities"
  add_foreign_key "users_authorities", "users"
end
