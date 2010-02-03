class AddIsSpecReceivedToPackage < ActiveRecord::Migration
  def self.up
    add_column :packages, :is_spec_received, :boolean, :default => false
  end

  def self.down
    remove_column :packages, :is_spec_received
  end
end
