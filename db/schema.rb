# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100202223901) do

  create_table "control_hooks", :force => true do |t|
    t.string   "name"
    t.string   "content"
    t.datetime "last_edit_at"
    t.boolean  "is_default",      :default => false
    t.integer  "last_edit_by_id"
    t.integer  "variant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "depends", :force => true do |t|
    t.string   "name"
    t.string   "compare_type"
    t.string   "version"
    t.integer  "variant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "packages", :force => true do |t|
    t.string   "name"
    t.string   "original_name"
    t.string   "version"
    t.text     "description"
    t.string   "authors"
    t.string   "project_uri"
    t.string   "gem_uri"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_spec_received", :default => false
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "encrypted_password", :limit => 128
    t.string   "salt",               :limit => 128
    t.string   "confirmation_token", :limit => 128
    t.string   "remember_token",     :limit => 128
    t.boolean  "email_confirmed",                   :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["id", "confirmation_token"], :name => "index_users_on_id_and_confirmation_token"
  add_index "users", ["remember_token"], :name => "index_users_on_remember_token"

  create_table "users_packages", :force => true do |t|
    t.integer  "user_id"
    t.integer  "package_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "variants", :force => true do |t|
    t.string   "platform"
    t.string   "arch"
    t.string   "lang"
    t.string   "sha256"
    t.string   "sha1"
    t.string   "md5"
    t.string   "size"
    t.boolean  "is_generated",  :default => false
    t.string   "state",         :default => "approved"
    t.integer  "package_id"
    t.integer  "created_by_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
