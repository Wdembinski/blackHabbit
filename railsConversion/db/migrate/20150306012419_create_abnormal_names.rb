class CreateAbnormalNames < ActiveRecord::Migration
  def change
    create_table :abnormal_names do |t|
      t.text :name
      t.integer :domain_cach_id
      t.timestamps null: false
    end
    add_foreign_key :abnormal_names, :domain_caches
  end
end
