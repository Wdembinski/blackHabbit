class Addforeignkeytohistories < ActiveRecord::Migration
  def change
  	add_foreign_key :histories, :domain_caches
  end
end
