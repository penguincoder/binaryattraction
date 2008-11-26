#!/usr/bin/env ruby

##
# This is my Facebook application for BinaryAttraction. It should be quick and
# easy to deal with. It has a simple interface into Facebook so that people
# can play with the application in Facebook. I do not plan on adding all of the
# features from the webapp into the Facebook application. Sorry. Get a life and
# log in like the rest of ... everyone.
#
# Supports:
# * hall of fame!
# * voting
# * adding facebook photos
# * checking stats
# * inviting your friends!
#

# libraries used
%w(rubygems frankie mysql active_record yaml memcache memcache_util).each do |lib|
  require lib
end
# require AR models
Dir.glob(File.dirname(__FILE__) + "/app/models/*.rb") { |m| require m }

##
# Logger setup for the Sinatra app.
#
def log
  @_logger ||= Logger.new($stderr)
end

##
# The BinaryAttraction User found by the facebook id of the currently logged
# in user.
#
def ba_user
  @_user ||= User.find_by_facebook_id(session[:facebook_session].user.id)
end

# Sinatra configuration
configure do
  set :sessions, true
  set :logging, log
  load_facebook_config File.dirname(__FILE__) + '/config/facebooker.yml', Sinatra.env
  begin
    log.debug "Using #{Sinatra.env} database environment"
    db_config = YAML::load_file(File.dirname(__FILE__) + '/config/database.yml')[Sinatra.env]
    ActiveRecord::Base.logger = log
    ActiveRecord::Base.establish_connection db_config
    ActiveRecord::Base.allow_concurrency = true
  rescue => exception
    log.fatal "There was a problem loading the database.yml file:"
    exception.backtrace.each do |msg|
      log.fatal "* #{msg}"
    end
    exit 1
  end
  config_path = File.dirname(__FILE__) + '/config/memcache.yml'
  if File.file?(config_path) and File.readable?(config_path)
    memcache_connection_str = YAML.load(File.read(config_path))
  else
    memcache_connection_str = 'localhost:11211'
  end
  CACHE = MemCache.new memcache_connection_str
end

configure :development do
  log.level = Logger::DEBUG
end

configure :production do
  log.level = Logger::FATAL
end

# facebooker helpers
before do
  ensure_authenticated_to_facebook
  ensure_application_is_installed_by_facebook_user
  User.create(:facebook_id => session[:facebook_session].user.id) if ba_user.nil?
end

# little welcome page, nothing much, really
post '/' do
  haml :index
end

# most oneable photos
post '/hall_of_fame' do
  @top_oneness = Photo.find :all, :order => 'oneness DESC, votes_count DESC, id DESC', :limit => 10, :conditions => 'oneness > 0'
  haml :hall_of_fame
end

# go to vote on a photo
post '/vote' do
  if params[:save]
    @vote = Vote.new :vote => (params[:one].to_s == 'true')
    @vote.user = ba_user
    @vote.photo = Photo.find(params[:photo_id].to_i) rescue nil
    unless @vote.save
      log.info "Failed to save the vote for some reason:"
      @vote.errors.each_full { |m| log.info "* #{m}" }
    end
  end
  @photo = Photo.next_available_votable_photo ba_user, true
  haml :vote
end

# import photos of yourself from facebook into BA. automatically tags photos
# uploaded with your facebook id so that you can look up the stats later. since
# facebook doesn't do 'not' boolean logic, you have to find all the photos then
# subtract all of the ones already added into ba
post '/add_photos' do
  @page = params[:page].to_i
  per_page = 20
  if params[:save]
    (0..per_page).each do |pidx|
      fb_photo_id = params["photo_ids[#{pidx}]"]
      break if fb_photo_id.nil?
      photo = Photo.new :facebook_id => fb_photo_id, :user_id => ba_user.id
      photo.email_hash = ba_user.facebook_id
      photo.approved = true
      unless photo.save
        log.info "Failed to save the photo:"
        photo.errors.each_full { |msg| log.info "* #{msg}" }
      end
    end
  end
  cache_key = "photos_of_#{ba_user.id}"
  @fb_photos = Cache.get(cache_key) if @page >= 0 or params[:save]
  @fb_photos ||= session[:facebook_session].get_photos nil, session[:facebook_session].user.id
  if @page == 0
    ba_photos = ba_user.photos.find(:all, :select => 'facebook_id', :conditions => 'facebook_id IS NOT NULL').collect { |p| p.facebook_id.to_i }
    @fb_photos.reject! { |p| ba_photos.include? p.pid.to_i } unless ba_photos.empty?
    Cache.put(cache_key, @fb_photos)
  end
  @min_page = @page - 3 < 0 ? 0 : @page - 3
  @max_page = @fb_photos.size / per_page
  @total_photo_count = @fb_photos.size
  @fb_photos = @fb_photos[@page * per_page, per_page]
  haml :add_photos
end

# check your voting record and the stats on photos of you
post '/stats' do
  photo_ids = Photo.find(:all, :select => 'id', :conditions => [ 'email_hash = ?', ba_user.facebook_id ]).collect { |p| p.id } rescue []
  @votes = Vote.find(:all, :conditions => "photo_id IN (#{photo_ids.join(',')})") rescue []
  haml :stats
end

# invite your friends to BA!
post '/invite' do
  haml :invite
end

use_in_file_templates!

__END__

@@ index
%style{ :type => 'text/css' }
  :sass
    h1
      text-align: center
    blockquote
      font-size: 16px
      padding: 5px 0px 5px 15px
      background-color: #eeeeee
      border-top: 1px dashed #9f9f9f
      border-right: 1px dashed #9f9f9f
      border-bottom: 1px solid #d4d4d4
      border-left: 1px solid #d4d4d4
      em
        margin-left: 20px
    .ftabs
      border-bottom: 1px solid #CCCCCC
      padding:0 10px 0 8px
      height: 24px
      #ajax_loading
        display: none
        float: right
        margin: 7px 16px 0 0
        height: 8px
        width: 28px
      a
        background: #F0F0F0 none repeat scroll 0 0
        border-left: 1px solid #E5E5E5
        border-right: 1px solid #CCCCCC
        border-top: 1px solid #CCCCCC
        color: #666666
        display: block
        float: left
        margin-top: 1px
        padding: 4px 8px
        position: relative
      .first
        border-left: 1px solid #CCCCCC
        margin-left: 0
      .last
        border-right: 1px solid #CCCCCC
      a:hover
        background: #fff
        color: #444
        text-decoration: none
      a:focus
        outline: 0px
      .active
        background: #FFFFFF none repeat scroll 0 0
        border-bottom: 1px solid #FFFFFF
        border-left: 1px solid #CCCCCC
        color: #333333
        margin-bottom: -1px
        margin-left: -1px
        margin-top: 0
        padding-bottom: 4px
        padding-top: 5px
    .caption
      color: #6F6F6F
      font-size: 11px
      font-weight: normal
      margin: 3px 0
    .photo_tabs
      padding: 20px 0
      h3
        height: 21px
        overflow: hidden
        padding: 0 10px
    .pagerpro
      font-size: 11px
      float: right
      list-style: none
      margin: 0
      padding: 0
      font-weight: normal
      li
        display: inline
        float: left
      a
        display: block
        padding: 3px 3px 2px
      a:hover
        background: #3B5998 none repeat scroll 0 0
        border-bottom: 1px solid #3B5998
        border-color: #D8DFEA #D8DFEA #3B5998
        color: #FFFFFF
        text-decoration: none
      .current
        a
          color: #3B5998
          cursor: pointer
          outline-style: none
          text-decoration: none
        a:hover
          background: transparent none repeat scroll 0 0
          border-bottom: 2px solid #3B5998
          border-color: #3B5998
          color: #FFF
          font-weight: bold
          padding-left: 2px
          padding-right: 2px
    .photos_table
      background: #F7F7F7 none repeat scroll 0 0
      border: 1px solid #BBBBBB
      margin: 0 0 20px
      overflow: hidden
      padding: 0
      position: relative
      width: 750px
      .table_wrapper
        padding: 0 5px
        margin: 0
      .photos_table_cell
        margin: 0
        padding: 10px 0
        text-align: center
        vertical-align: middle
        width: 150px
        img
          background: white none repeat scroll 0 0
          border: 1px solid #CCCCCC
          padding: 5px
          vertical-align: middle
        img:hover
          border: 1px solid #3B5998
        a
          color: #3B5998
          cursor: pointer
          outline-style: none
          text-decoration: none
    .top_oneness
      list-style-type: none
      width: 450px
      margin-left: auto
      margin-right: auto
      li
        background-color: #e9b96e
        border: 1px solid #c17d11
        padding: 3px 10px
        margin-bottom: 10px
        img
          display: block
          margin-left: auto
          margin-right: auto
      p
        text-align: center
    #vote_container
      width: 604px
      margin: 0 auto 10px auto
      img
        display: block
        margin-left: auto
        margin-right: auto
    #vote_controls
      margin-left: auto
      margin-right: auto
      border: 1px solid #c17d11
      background-color: #e9b96e
      width: 66px
      height: 32px
      img
        padding: 5px
        width: 22px
        height: 22px
        float: left
    .poll_results
      width: 420px
      h2
        background-color: #6D84B4
        color: #FFF
        font-size: 11px
        padding: 5px
        margin: 0
      .poll_answers
        background: #FFF none repeat scroll 0 0
        border-color: #CCCCCC
        border-style: solid
        border-width: 0 1px 1px
        padding: 5px
      p
        margin: 0
        font-weight: bold
      table
        margin: 10px 0 10px 0
      .label
        padding-right: 10px
        text-align: right
        font-size: 11px
      .bar
        background-attachment: scroll
        background-color: #3B5998
        background-image: none
        background-position: 0 0
        background-repeat: repeat
        float: left
        height: 18px
        margin-right: 5px
        color: #FFF
        text-align: left
        font-weight: bold
        font-size: 13px
        padding: 1px 1px 1px 3px

:javascript
  function run_ajax_request(url, params)
  {
    document.getElementById('ajax_loading').setStyle('display', 'inline');
    var a_request = new Ajax();
    a_request.responseType = Ajax.FBML;
    a_request.requireLogin = true;
    a_request.ondone = function(data) {
      document.getElementById('ajax_loading').setStyle('display', 'none');
      document.getElementById('ba_content').setInnerFBML(data);
      if(document.getElementById('error').getStyle('display') != 'none')
        Animation(document.getElementById('error')).to('height', '0px').to('opacity', 0).hide().go();
    }
    a_request.onerror = function() {
      document.getElementById('ajax_loading').setStyle('display', 'none');
      Animation(document.getElementById('error')).to('height', 'auto').from('0px').to('width', 'auto').from('0px').to('opacity', 1).from(0).blind().show().go();
    }
    a_request.post('http://facebook.binaryattraction.com/' + url, params);
  }
  var oldtab = '';
  function switch_tab(name)
  {
    var oldtab_elem = document.getElementById('tab_' + oldtab);
    if(oldtab_elem)
      oldtab_elem.removeClassName('active');
    oldtab = name;
    document.getElementById('tab_' + oldtab).addClassName('active');
    run_ajax_request(name);
  }
  function switch_photos(page)
  {
    run_ajax_request('add_photos', {'page':page});
  }
  function vote_photo(pid, one)
  {
    run_ajax_request('vote', {'photo_id':pid, 'save':true, 'one':one});
  }
  function highlight_photo(pid)
  {
    var img_elem = document.getElementById('photo_' + pid);
    var input_elem = document.getElementById('input_' + pid);    if(!input_elem.getChecked())
    {
      Animation(img_elem).to('background', '#ffff4b').from('#fff').go();
      input_elem.setChecked(true);
    } else {
      Animation(img_elem).to('background', '#fff').from('#ffff4b').go();
      input_elem.setChecked(false);
    }
  }
  function add_photos()
  {
    run_ajax_request('add_photos', document.getElementById('add_photos_form').serialize());
  }

%div#error{ :style => 'display: none; overflow: hidden' }
  %fb:error{ :message => 'Sorry, there was a problem communicating to the binary|Attraction servers...' }
%div.ftabs
  %a{ :id => 'tab_hall_of_fame', :href => '#', :onclick => "switch_tab('hall_of_fame');return false;", :class => "first" } Hall Of Fame
  %a{ :id => 'tab_vote', :href => '#', :onclick => "switch_tab('vote');return false;" } Vote
  %a{ :id => 'tab_add_photos', :href => '#', :onclick => "switch_tab('add_photos');return false;" } Add Photos
  %a{ :id => 'tab_stats', :href => '#', :onclick => "switch_tab('stats');return false;" } Stats
  %a{ :id => 'tab_invite', :href => '#', :onclick => "switch_tab('invite');return false;", :class => "last" } Invite Your Friends
  %img#ajax_loading{ :alt => 'loading', :src => 'http://static.ak.fbcdn.net/images/upload_progress.gif?1:25923' }
%br{ :style => 'clear: both' }
%div#ba_content
  %img{ :src => 'http://binaryattraction.com/images/binaryattraction.png', :style => 'display: block; margin-left: auto; margin-right: auto' }
  %h1 What this is all about
  %blockquote
    All you young guys are on a binary system. It's either <tt>0</tt> or <tt>1</tt>.
    %br
    %em Larry Bell
  %blockquote
    All you old guys are on the analog system. Join the digital revolution.
    %br
    %em Ross Bagwell
  %br
  %p.caption{ :style => 'text-align: center' } Check out our <a href="http://binaryattraction.com">home page</a> | Produced by <a href="http://penguincoder.org">PenguinCoder</a>

@@ hall_of_fame
%h1 Top oneness
%ol.top_oneness
  - @top_oneness.each_with_index do |p, index|
    %li
      - if p.facebook_id.to_i == 0
        %img{ :style => 'display: block; margin: 0px auto', :src => "http://binaryattraction.com/photos/#{p.id}/thumbnail?width=300&height=300" }
      - else
        %fb:photo{ :pid => p.facebook_id, :size => 'album' }
      %p{ :style => 'text-align: center' }== <strong>Oneness:</strong> #{p.oneness}% <strong>Votes 0:</strong> #{p.zero_votes} <strong>Votes 1:</strong> #{p.one_votes} <strong>Total Votes:</strong> #{p.votes_count}

@@ vote
- if @photo.nil?
  %fb:explanation{ :message => 'You have run out of photos to vote! Try adding some more' }
- else
  %div#vote_container
    - if @photo.facebook_id
      %fb:photo{ :pid => @photo.facebook_id, :size => 'normal' }
    - else
      %img{ :src => "http://binaryattraction.com#{@photo.pathname}", :alt => @photo.filename, :width => @photo.width, :height => @photo.height }
  %div#vote_controls
    %a{ :href => '#', :onclick => "vote_photo(#{@photo.id}, false); return false;", :title => '0-able' }
      %img{ :src => 'http://binaryattraction.com/images/0.png' }
    %a{ :href => '#', :onclick => "vote_photo(#{@photo.id}, true); return false;", :title => '1-able' }
      %img{ :src => 'http://binaryattraction.com/images/1.png' }

@@ add_photos
%div.photo_tabs
  %h3
    %ul.pagerpro
      - if @page > 0
        %li
          %a{ :href => '#', :onclick => "switch_photos(#{@page - 1});return false;" } Prev
      - @min_page.upto(@max_page) do |pnum|
        - if pnum == @page
          %li.current
            %a{ :href => '#', :onclick => 'return false;' }= pnum + 1
        - else
          %li
            %a{ :href => '#', :onclick => "switch_photos(#{pnum});return false;" }= pnum + 1
      - if @page < @max_page
        %li
          %a{ :href => '#', :onclick => "switch_photos(#{@page + 1});return false;" } Next
    %span== Photos of #{session[:facebook_session].user.first_name}
    %span.caption== #{@total_photo_count} photos | Pick some photos | Try to choose images of just yourself
  %form{ :id => 'add_photos_form' }
    %input{ :type => 'hidden', :name => 'save', :value => 'true' }
    %div.photos_table
      %div.table_wrapper
        %table
          %tbody
            - @fb_photos.each_slice(5) do |slice|
              %tr
                - slice.each do |photo|
                  %td.photos_table_cell
                    %fb:photo{ :pid => photo.pid, :size => 'small', :id => "photo_#{photo.pid}", :onclick => "highlight_photo('#{photo.pid}'); return false;" }
                    %input{ :style => 'display: none', :type => 'checkbox', :name => "photo_ids[]", :id => "input_#{photo.pid}", :value => photo.pid }
    %input{ :type => 'button', :class => 'inputbutton', :value => 'Add Photos', :onclick => "add_photos(); return false;" }

@@ stats
%div.poll_results
  %h2== Your oneness from #{@votes.size} votes
  %div.poll_answers
    %table
      %tbody
        %tr
          %td
            %p.label Oneness
          %td
            - oneness = "%.1f" % (@votes.select { |v| v.one? }.size.to_f / @votes.size.to_f * 100.0)
            %div.bar{ :style => "width: #{240 * oneness.to_i / 100}px" }== #{oneness}%
        %tr
          %td
            %p.label Votes 1
          %td= @votes.select { |v| v.one? }.size
        %tr
          %td
            %p.label Votes 0
          %td= @votes.select { |v| v.zero? }.size
%br
%div.poll_results
  %h2== Your voting results for #{ba_user.votes.size} photos
  %div.poll_answers
    %table
      %tbody
        %tr
          %td
            %p.label Oneness
          %td
            - oneness = "%.1f" % (ba_user.votes.select { |v| v.one? }.size.to_f / ba_user.votes.size.to_f * 100.0)
            %div.bar{ :style => "width: #{240 * oneness.to_i / 100}px" }== #{oneness}%
        %tr
          %td
            %p.label Votes 1
          %td= ba_user.votes.select { |v| v.one? }.size
        %tr
          %td
            %p.label Votes 0
          %td= ba_user.votes.select { |v| v.zero? }.size

@@ invite
%fb:request-form{ :type => 'Binary Attraction', :content => "Your friends think you should check out your oneness at <fb:req-choice url='http://apps.facebook.com/binaryattraction' label='Binary Attraction' />", :action => 'http://apps.facebook.com/binaryattraction', :invite => true, :method => 'POST' }
  %fb:multi-friend-selector{ :actiontext => "Invite your friends to vote on ones (and not ones)", :showborder => true, :exclude_ids => session[:facebook_session].user.friends_with_this_app.map(&:id).join(","), :bypass => "cancel" }
