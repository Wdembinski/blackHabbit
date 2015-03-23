class CreateNmcChainLinks < ActiveRecord::Migration
  def change
    create_table :nmc_chain_links do |t|


      t.jsonb :link, null: false, default: '{}'

      t.timestamps null: false
    end
     add_index  :nmc_chain_links, :link, using: :gin
  end
end
