class CreateUsersPackages < ActiveRecord::Migration
  def self.up
    create_table :users_packages do |t|
      t.integer     :user_id
      t.integer     :package_id
      t.timestamps
    end
  end

  def self.down
    drop_table :users_packages
  end
end
