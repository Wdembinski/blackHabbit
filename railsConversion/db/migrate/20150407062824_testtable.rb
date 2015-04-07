class Testtable < ActiveRecord::Migration
  def change
  	create_table "test_nmc_entries", force: :cascade do |t|
  	  t.jsonb    "link",       default: {}, null: false
  	  t.datetime "created_at",              null: false
  	  t.datetime "updated_at",              null: false
  	end

  	add_index "test_nmc_entries", ["link"], name: "index_test_nmc_entries_on_link", using: :gin

  end
end
