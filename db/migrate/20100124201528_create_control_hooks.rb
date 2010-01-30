class CreateControlHooks < ActiveRecord::Migration
  
  def self.up
    create_table :control_hooks do |t|
      t.string      :name
      t.string      :content
      t.datetime    :last_edit_at
      t.boolean     :is_default, :default => false
      t.integer     :last_edit_by_id
      
      t.integer     :variant_id
      t.timestamps
    end
  end

  def self.down
    drop_table :control_hooks
  end
end
