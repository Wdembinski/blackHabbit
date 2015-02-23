class UpdateDomainCache < ActiveRecord::Migration
  def change
    add_index :domain_caches, :value
    add_index :domain_caches, :name
  	
  end
end
