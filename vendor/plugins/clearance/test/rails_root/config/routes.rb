ActionController::Routing::Routes.draw do |map|
  map.resource  :account

  map.root :controller => 'accounts', :action => 'edit'
end
