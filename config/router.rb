Merb.logger.info("Compiling routes...")
Merb::Router.prepare do |r|
  r.match('/').to( :controller => 'home', :action => 'index' )
  r.match('/acceptable_use').to( :controller => 'home', :action => 'acceptable_use' )
  r.match('/hall_of_fame').to(:controller => 'home', :action => 'hall_of_fame')
  
  r.resources :sessions
  r.resources :users
  r.resources :people
  r.resources :votes
  r.resources :favorites
  r.match('/photos/thumbnail/:id').to(:controller => 'photos', :action => 'thumbnail')
  r.resources :photos
end
