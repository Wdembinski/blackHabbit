class CreateAbnormalJsons < ActiveRecord::Migration
  def change
    create_table :abnormal_jsons do |t|
      t.integer :nmc_chain_link_id

      t.timestamps null: false
    end
    add_foreign_key :abnormal_jsons, :nmc_chain_link_id

  end
end
