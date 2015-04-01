class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
    	t.text :value
      t.timestamps null: false
    end
  end
end
