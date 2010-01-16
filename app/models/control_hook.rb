class ControlHook
  include MongoMapper::EmbeddedDocument
  
  key :name, String
  key :content, String
  key :last_edit_at, Time
  belongs_to :last_edit_by, :class => User
end