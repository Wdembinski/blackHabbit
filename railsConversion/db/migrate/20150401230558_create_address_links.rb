class CreateAddressLinks < ActiveRecord::Migration
  def change
    create_table :address_links do |t|
    	t.belongs_to :address
    	t.belongs_to :hyperlink
      t.timestamps null: false	
    end
  end
end
