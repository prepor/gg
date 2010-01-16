class Depend
  Types = ['<<', '<=', '=', '>=', '>>']
  
  include MongoMapper::EmbeddedDocument
  
  key :name, String
  key :type, String
  key :version, String
  
  def for_list
    name + (version.present? ? " (#{type} #{version})" : '')
  end
  
end