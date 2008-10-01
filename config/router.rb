Merb.logger.info("Compiling routes...")
Merb::Router.prepare do |r|
  r.resources :sessions
  r.resources :users
  r.resources :people
  r.resources :votes
  r.resources :photos
  r.resources :favorites
  r.resources :stats
  # r.default_routes
  r.match('/').to( :controller => 'home', :action => 'index' )
  r.match('/acceptable_use').to( :controller => 'home', :action => 'acceptable_use' )
end
