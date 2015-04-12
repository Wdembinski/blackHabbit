class CreateDbBatches < ActiveRecord::Migration
  def change
    create_table :db_batches do |t|

      t.timestamps null: false
    end
  end
end
