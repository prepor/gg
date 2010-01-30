class ControlHooksController < InheritedResources::Base
  nested_belongs_to :package, :variant
  actions :show  
end

