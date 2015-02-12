class CreateSearches < ActiveRecord::Migration
  def change
    create_table :searches do |t|
      t.string :userQuery

      t.timestamps null: false
    end
  end
end
