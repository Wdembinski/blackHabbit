class CreateAbnormalJson < ActiveRecord::Migration
  def change
    create_table :abnormal_json do |t|
      t.integer :nmc_chain_link_id
      t.timestamps null: false
    end
    add_foreign_key :abnormal_json, :nmc_chain_links
  end
end
