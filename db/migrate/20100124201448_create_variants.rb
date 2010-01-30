class CreateVariants < ActiveRecord::Migration
  def self.up
    create_table :variants do |t|
      t.string  :platform
      t.string  :arch
      t.string  :lang
      t.string  :sha256
      t.string  :sha1
      t.string  :md5
      t.string  :size
      
      t.boolean :is_generated, :default => false
      t.string :state, :default => 'approved' 
      
      t.integer :package_id
      
      t.timestamps
    end
  end

  def self.down
    drop_table :variants
  end
end
