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

ActiveRecord::Schema.define(version: 20150322194334) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "abnormal_json", force: :cascade do |t|
    t.integer  "nmc_chain_link_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "abnormal_names", force: :cascade do |t|
    t.integer  "domain_cache_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "domain_caches", force: :cascade do |t|
    t.text    "name"
    t.text    "value"
    t.integer "expires_in"
  end

  add_index "domain_caches", ["name"], name: "index_domain_caches_on_name", using: :btree
  add_index "domain_caches", ["value"], name: "index_domain_caches_on_value", using: :btree

  create_table "histories", force: :cascade do |t|
    t.text     "transactionId"
    t.text     "address"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "domain_cache_id"
  end

  create_table "json_histories", force: :cascade do |t|
    t.jsonb    "history",           default: {}, null: false
    t.integer  "nmc_chain_link_id"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "json_histories", ["history"], name: "index_json_histories_on_history", using: :gin

  create_table "nmc_chain_links", force: :cascade do |t|
    t.jsonb    "link",       default: {}, null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "nmc_chain_links", ["link"], name: "index_nmc_chain_links_on_link", using: :gin

  create_table "possible_addresses", force: :cascade do |t|
    t.integer  "domain_cache_id"
    t.string   "address"
    t.text     "links"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "searches", force: :cascade do |t|
    t.string   "userQuery"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "abnormal_json", "nmc_chain_links"
  add_foreign_key "abnormal_names", "domain_caches", column: "domain_cache_id"
  add_foreign_key "histories", "domain_caches", column: "domain_cache_id"
  add_foreign_key "json_histories", "nmc_chain_links"
end
