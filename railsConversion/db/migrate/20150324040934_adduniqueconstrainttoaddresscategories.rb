class Adduniqueconstrainttoaddresscategories < ActiveRecord::Migration
  def change
  	add_index :possible_address_categories, :name, :unique => true
  end
end
