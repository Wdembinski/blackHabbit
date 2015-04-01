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

ActiveRecord::Schema.define(version: 20150401223935) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "abnormal_jsons", force: :cascade do |t|
    t.integer  "nmc_chain_link_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "addresses", force: :cascade do |t|
    t.integer  "nmc_chain_entry_id",                             null: false
    t.string   "address",                                        null: false
    t.text     "links"
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.string   "regex_match",        limit: 200
    t.boolean  "categorized",                    default: false
  end

  add_index "addresses", ["address"], name: "index_possible_addresses_on_address", using: :btree
  add_index "addresses", ["categorized"], name: "boolean_index_possibleaddr", using: :btree

  create_table "category_memberships", force: :cascade do |t|
    t.integer  "possible_address_id",          null: false
    t.integer  "possible_address_category_id", null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "category_memberships", ["possible_address_category_id"], name: "index_category_memberships_on_possible_address_category_id", using: :btree
  add_index "category_memberships", ["possible_address_id", "possible_address_category_id"], name: "category_memberships_possible_address_id_possible_address_c_key", unique: true, using: :btree
  add_index "category_memberships", ["possible_address_id"], name: "index_category_memberships_on_possible_address_id", using: :btree

  create_table "hyperlinks", force: :cascade do |t|
    t.integer  "address_id"
    t.text     "link",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "hyperlinks", ["address_id"], name: "index_hyperlinks_on_address_id", using: :btree

  create_table "json_histories", force: :cascade do |t|
    t.jsonb    "history",           default: {}, null: false
    t.integer  "nmc_chain_link_id",              null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "json_histories", ["history"], name: "index_json_histories_on_history", using: :gin

  create_table "nmc_addresses", force: :cascade do |t|
    t.integer  "address_id"
    t.integer  "nmc_chain_entry_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "nmc_addresses", ["address_id"], name: "index_nmcaddresses_on_address_id", using: :btree
  add_index "nmc_addresses", ["nmc_chain_entry_id"], name: "index_nmcaddresses_on_nmc_chain_entry_id", using: :btree

  create_table "nmc_chain_entries", force: :cascade do |t|
    t.jsonb    "link",       default: {}, null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "nmc_chain_entries", ["link"], name: "index_nmc_chain_links_on_link", using: :gin

  create_table "possible_address_categories", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "possible_address_categories", ["name"], name: "index_possible_address_categories_on_name", unique: true, using: :btree

  create_table "test_tables", force: :cascade do |t|
    t.text     "key"
    t.text     "val"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "abnormal_jsons", "nmc_chain_entries", column: "nmc_chain_link_id"
  add_foreign_key "json_histories", "nmc_chain_entries", column: "nmc_chain_link_id"
end
