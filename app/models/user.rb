class User
  include MongoMapper::Document
  include Clearance::User
  
  key :name, String
  key :package_ids, Array
  
  many :packages, :in => :package_ids
end