class CreateAddressCategoriesJoins < ActiveRecord::Migration
  def change
    create_table :address_categories_joins do |t|
    	t.belongs_to :possible_address, index: true
    	t.belongs_to :possible_address_category, index: true
      t.timestamps null: false
    end
    # add_index :address_categories_joins, [:possible_address, :possible_address_category], unique: true
  end   #need to make this shorter I gues???  its says the title of the index is too long.  Will do soon.
end
