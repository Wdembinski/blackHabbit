class CreateDomainCache < ActiveRecord::Migration
  def change
    create_table :domain_caches do |t|
    	t.string :name
    	t.string :value
    	t.integer :expires_in
    	t.timestamps
    end
  end
end

