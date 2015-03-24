class CreatePossibleAddressCategories < ActiveRecord::Migration
  def change
    create_table :possible_address_categories do |t|
      t.string :name
      t.text :description
      t.timestamps null: false
    end
    add_column :possible_addresses, :possible_address_category_id, :integer
    add_foreign_key :possible_addresses,:possible_address_categories
  end
end
