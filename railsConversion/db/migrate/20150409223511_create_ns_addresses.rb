class CreateNsAddresses < ActiveRecord::Migration
  def change
    create_table :ns_addresses do |t|
      t.references :address, index: true
      t.integer :ns_address_id, index: true

      t.timestamps null: false
    end
    add_foreign_key :ns_addresses, :addresses
  end
end
