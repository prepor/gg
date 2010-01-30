class CreateDepends < ActiveRecord::Migration
  def self.up
    create_table :depends do |t|
      t.string      :name
      t.string      :compare_type
      t.string      :version
      
      t.integer     :variant_id
      t.timestamps
    end
  end

  def self.down
    drop_table :depends
  end
end
