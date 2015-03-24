class CreateCategoryMemberships < ActiveRecord::Migration
  def change
    create_table :category_memberships do |t|
    	t.belongs_to :possible_address, index: true
    	t.belongs_to :possible_address_category, index: true
      t.timestamps null: false
    end
    # add_index :relationships, [:possible_address, :possible_address_category], unique: true
  end
end
