class FixPossibleAddresses < ActiveRecord::Migration
  def change
    create_table :possible_addresses do |t|
      t.integer :domain_cache_id
      t.string :address
      t.text :links
      t.timestamps null: false
    end
  end
end
