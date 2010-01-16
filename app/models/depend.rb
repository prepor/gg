class Depend
  Types = ['<<', '<=', '=', '>=', '>>']
  
  key :name, String
  key :type, String
  key :version, String
  
  def for_list
    "#{name} (#{type} #{version})"
  end
  
end