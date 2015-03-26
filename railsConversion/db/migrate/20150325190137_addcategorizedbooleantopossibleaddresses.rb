class Addcategorizedbooleantopossibleaddresses < ActiveRecord::Migration
  def change
  	add_column :possible_addresses, :categorized, :boolean
  end
end
