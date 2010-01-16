class User
  include MongoMapper::Document
  include Clearance::User
  
  key :name, String
end