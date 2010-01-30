class CreatePackages < ActiveRecord::Migration
  def self.up
    create_table :packages do |t|
      t.string  :name
      t.string  :original_name
      
      t.string  :version
      
      t.text    :description
      
      t.string  :authors
      
      t.string  :project_uri
      t.string  :gem_uri

      t.timestamps
    end
  end

  def self.down
    drop_table :packages
  end
end
