class AddIndexToPossibleAddressesAddress < ActiveRecord::Migration
  def change
  	add_index(:possible_addresses, :address)
  end
end
