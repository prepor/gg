ActionController::Routing::Routes.draw do |map|
  map.resources :users
  
  Clearance::Routes.draw(map)
  
  map.resources :packages do |package|
    package.resources :variants, :member => { :approve => :put, :decline => :put } do |variant|
      variant.resources :control_hooks
    end
  end
  
  map.connect 'help', :controller => 'root', :action => 'help'
  
  map.root :controller => 'root'
end
