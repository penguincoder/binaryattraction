class Users < Application
  before :fetch_allowed_user, :only => [ :edit, :update, :destroy ]
  before :administrator?, :only => [ :destroy ]
  
  include Ambethia::ReCaptcha::Controller
  
  def index
    if logged_in? and current_user.administrator?
      @users = User.find :all, :order => 'user_name ASC', :conditions => 'facebook_id IS NULL'
      render
    else
      redirect url(:user, :id => current_user.user_name)
    end
  end
  
  def new
    @user = User.new
    render
  end
  
  def create
    @user = User.new params[:user]
    @user.user_name = params[:user][:user_name] rescue nil
    if verify_recaptcha(@user) and @user.save
      flash[:notice] = 'Great success'
      redirect '/'
    else
      flash[:error] = 'The user could not be created...'
      render :new
    end
  end
  
  def edit
    render
  end
  
  def update
    @user.attributes = params[:user] if params[:user]
    if @user.save
      flash[:notice] = 'Great success'
      redirect '/'
    else
      render :edit
    end
  end
  
  def destroy
    raise NotAllowed unless request.xhr?
    if @user.destroy
      flash[:notice] = "Epic failure, goodbye #{@user.user_name}"
      reset_session if @user.id == session[:user_id]
    else
      flash[:error] = 'That did not work...'
    end
    redirect url(:users)
  end
  
  def validate_anonymous_user
    if logged_in? or valid_anonymous_user?
      flash[:notice] = 'You are already good, doofus.'
      redirect '/'
    elsif request.post? and !verify_recaptcha
      flash.now[:error] = 'That does not work. Try again.'
      render
    elsif request.post?
      valid_anonymous_user!
      flash[:notice] = 'Great success!'
      redirect url(:new_vote)
    else
      render
    end
  end
end
