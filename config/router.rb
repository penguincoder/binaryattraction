Merb.logger.info("Compiling routes...")
Merb::Router.prepare do |r|
  # custom routes for specific thingeys
  r.match('/').to(:controller => 'home', :action => 'index')
  r.match('/acceptable_use').to(:controller => 'home', :action => 'acceptable_use')
  r.match('/disclaimer').to(:controller => 'home', :action => 'disclaimer')
  r.match('/hall_of_fame').to(:controller => 'home', :action => 'hall_of_fame')
  
  # restful things
  r.resources :sessions
  r.resources :users
  r.resources :votes
  r.resources :favorites
  r.resources :photos, :member => { :thumbnail => :get }
end
