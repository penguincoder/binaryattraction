class Votes < Application
  before :validate_anonymous_user
  before :fetch_allowed_user, :only => [ :show ]
  
  def show
    @page = params[:page].to_i
    per_page = 4
    @votes = @user.votes.find :all, :limit => per_page, :offset => (@page * per_page)
    @page_count = (@user.votes.size.to_f / per_page.to_f).ceil
    if @votes.empty?
      flash[:notice] = 'You need to vote, first'
      redirect url(:new_vote)
    end
    if request.xhr?
      partial 'votes/stats_for_user'
    else
      render
    end
  end
  
  def new
    get_mah_fohtoh
    render
  end
  
  def create
    raise NotAllowed unless request.xhr?
    @photo = Photo.find params[:photo_id] rescue nil
    @vote = Vote.new :photo_id => (@photo.id rescue true), :vote => (params[:one].to_s == 'true')
    if logged_in?
      @vote.user_id = current_user.id
    else
      @vote.session_id = current_user
    end
    if @vote.save
      get_mah_fohtoh
      partial 'votes/voting'
    else
      emsg = "The vote failed: "
      @vote.errors.each_full { |e| emsg += e + ' ' }
      render emsg, :status => 401, :layout => false
    end
  end
  
  private
  
  def get_mah_fohtoh
    # just a simple check to not allow you to vote on a photo twice. model
    # business logic will fail this, too, but just to make sure you don't...
    @photo = Photo.find params[:photo_id] if params[:photo_id]
    if @photo.nil? or Vote.voted_for?(@photo, current_user)
      @photo = Photo.next_available_votable_photo current_user
    end
  end
  
  def validate_anonymous_user
    if !logged_in? and !valid_anonymous_user?
      flash[:notice] = 'You must prove that you are a human to continue.'
      redirect '/validate_anonymous_user'
    else
      true
    end
  end
end
