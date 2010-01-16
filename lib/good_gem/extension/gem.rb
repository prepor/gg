module GoodGem::Extension::Gem
  
  def self.included(base)
    base.extend GoodGem::Extension::Gem::Class
  end
  
  module Instance
  
    def minor
    
    end
  
    def major
    
    end
  
    def patch
      parts
    end
  end
  
  module Class  
    def to_mongo(value)
      value.to_s
    end
  
    def from_mongo(value)
      Gem::Version.new(value)
    end
  
  end
end