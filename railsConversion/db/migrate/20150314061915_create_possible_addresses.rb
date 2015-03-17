class CreatePossibleAddresses < ActiveRecord::Migration
  def change
    create_table :possible_addresses do |t|
      t.integer :domain_cache_id
      t.string :ipAddress

      t.timestamps null: false
    end
  end
end
