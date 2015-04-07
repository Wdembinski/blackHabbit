class CreateAddressTags < ActiveRecord::Migration
  def change
    create_table :address_tags do |t|
    	t.belongs_to :tag
    	t.belongs_to :address
      t.timestamps null: false
    end
  end
end
