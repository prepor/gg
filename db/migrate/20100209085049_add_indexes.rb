class AddIndexes < ActiveRecord::Migration
  def self.up
    add_index :variants, :state
    add_index :depends, :variant_id
    add_index :variants, :package_id
  end

  def self.down
    remove_index :variants, :package_id
    remove_index :depends, :variant_id
    remove_index :variants, :package_id
  end
end
