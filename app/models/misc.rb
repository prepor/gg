class Misc
  include MongoMapper::Document
  
  key :key, String
  key :value, Hash
end