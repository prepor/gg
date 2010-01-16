class User
  include MongoMapper::Document
  include Clearance::User
end