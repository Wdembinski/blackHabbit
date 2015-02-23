class RemoveNullOnTimeStamps < ActiveRecord::Migration
  def change
  	change_column_null(:domain_caches, :updated_at, true)
  	change_column_null(:domain_caches, :created_at, true)
  end
end
