# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150222143327) do

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   limit: 4,     default: 0, null: false
    t.integer  "attempts",   limit: 4,     default: 0, null: false
    t.text     "handler",    limit: 65535,             null: false
    t.text     "last_error", limit: 65535
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "freeagent_accounts", force: :cascade do |t|
    t.integer  "user_id",       limit: 4
    t.string   "uid",           limit: 255
    t.string   "email",         limit: 255
    t.string   "token",         limit: 255
    t.string   "refresh_token", limit: 255
    t.integer  "expires_at",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "stripe",        limit: 4
    t.integer  "main",          limit: 4
  end

  add_index "freeagent_accounts", ["user_id"], name: "index_freeagent_accounts_on_user_id", using: :btree

  create_table "imports", force: :cascade do |t|
    t.integer  "user_id",              limit: 4
    t.integer  "stripe_account_id",    limit: 4
    t.integer  "freeagent_account_id", limit: 4
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "success",              limit: 1,     default: false
    t.text     "log",                  limit: 65535
    t.string   "token",                limit: 255
  end

  add_index "imports", ["freeagent_account_id"], name: "index_imports_on_freeagent_account_id", using: :btree
  add_index "imports", ["stripe_account_id"], name: "index_imports_on_stripe_account_id", using: :btree
  add_index "imports", ["user_id"], name: "index_imports_on_user_id", using: :btree

  create_table "stripe_accounts", force: :cascade do |t|
    t.integer  "user_id",         limit: 4
    t.string   "token",           limit: 255
    t.string   "publishable_key", limit: 255
    t.string   "stripe_user_id",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_updated"
    t.string   "uid",             limit: 255
    t.string   "label",           limit: 255
    t.datetime "import_from"
  end

  add_index "stripe_accounts", ["user_id"], name: "index_stripe_accounts_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "token",                  limit: 255
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
