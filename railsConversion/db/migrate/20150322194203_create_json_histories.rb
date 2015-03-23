class CreateJsonHistories < ActiveRecord::Migration
  def change
    create_table :json_histories do |t|
      t.jsonb :history, null: false, default: '{}'
      t.integer :nmc_chain_link_id

      t.timestamps null: false
    end
     add_index  :json_histories, :history, using: :gin
     add_foreign_key :json_histories, :nmc_chain_links, column: :nmc_chain_link_id
  end
end



