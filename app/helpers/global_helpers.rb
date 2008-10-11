module Merb
  module GlobalHelpers
    def error_messages(obj)
      if obj.errors.empty?
        nil
      else
        "<div id='model_errors'><ul>#{obj.errors.each_full { |msg| "<li>#{msg}</li>" }}</ul></div>"
      end
    end
    
    def photo_url(photo, w = nil, h = nil)
      w = photo.width if w.nil? or w > photo.width
      h = photo.height if h.nil? or h > photo.height
      url :controller => 'photos', :action => 'thumbnail', :width => w, :height => h, :id => photo.id
    end
    
    def indicator
      "<img src='/images/ajax-loader.gif' id='indicator' style='display: none; vertical-align: middle' />"
    end
    
    def menu_items
      if @menu_items.nil?
        @menu_items = [
          { :img => '/images/face-monkey.png', :name => 'Hall of fame', :title => 'B.A. Hall of famers -- The oneest of the ones!', :href => '/hall_of_fame' },
          { :img => '/images/vote.png', :name => 'Vote', :title => 'Vote on new photos', :href => url(:new_vote) },
          { :img => '/images/image-x-generic.png', :name => 'Photos', :title => 'Browse the oneness!', :href => url(:photos) }
        ]
        if logged_in?
          @menu_items << { :img => '/images/utilities-system-monitor.png', :name => 'Stats', :title => 'Check your voting record against popular opinion', :href => url(:vote, :id => current_user.user_name) }
          @menu_items << { :img => '/images/camera-photo.png', :name => 'Upload', :title => 'Upload photos', :href => url(:new_photo) }
          @menu_items << { :img => '/images/emblem-favorite.png', :name => 'Favorites', :title => 'Check your favorites', :href => url(:favorite, :id => current_user.user_name) }
          @menu_items << { :img => '/images/system-lock-screen.png', :name => 'Settings', :title => 'Change your password', :href => url(:edit_user, :id => current_user.user_name) }
        else
          @menu_items << { :img => '/images/system-users.png', :name => 'Sign up', :title => 'Sign up for an account', :href => url(:new_user) }
          @menu_items << { :img => '/images/system-lock-screen.png', :name => 'Log in', :title => 'Log in with your account', :href => url(:new_session) }
        end
      end
      @menu_items
    end
    
    def pagination(block_name, base_url)
      @pagination_block = block_name
      @base_pagination_url = base_url
      partial 'home/pagination_script'
    end
  end
end
