class CreateDomainCache < ActiveRecord::Migration
  def change
    create_table :domain_caches do |t|
    		  t.text :name 
    		  t.text :value 
    	   	  t.integer :expires_in
    		  t.timestamps null: false    	
    end
  end
end
