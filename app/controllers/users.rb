class Users < Application
  before :fetch_allowed_user, :only => [ :show, :edit, :update, :delete ]
  before :prepare_user, :only => [ :show, :edit, :update, :delete ]
  
  include Ambethia::ReCaptcha::Controller
  
  def index
    if current_user.administrator?
      @users = User.find :all, :order => 'user_name ASC'
      render
    else
      redirect url(:user, :id => current_user.user_name)
    end
  end
  
  def show
    render
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
    if @user.save
      flash[:notice] = 'Great success'
      redirect url(:users)
    else
      render :edit
    end
  end
  
  def delete
    if @user.destroy
      flash[:notice] = "Epic failure, goodbye #{@user.user_name}"
      reset_session if @user.id == session[:user_id]
    else
      flash[:error] = 'That does not work...'
    end
    redirect url(:users)
  end
  
  protected
  
  def prepare_user
    @user.attributes = params[:user] if params[:user] and request.post?
  end
end
