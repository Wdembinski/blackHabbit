class CreateHistories < ActiveRecord::Migration
  def change
    create_table :histories do |t|
      t.text :transactionId
      t.text :address
      t.integer :domain_cach_id
      t.timestamps null: false
    end
    add_foreign_key :histories, :domain_caches

    # add_index :domain_caches, :transactionId
    # add_index :domain_caches, :address
  end
end
