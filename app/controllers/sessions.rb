class Sessions < Application
  def index
    redirect '/'
  end
  
  def new
    render
  end
  
  def create
    user = User.find_by_user_name params[:user_name]
    if user.authenticated_against?(params[:password])
      session[:user_id] = user.id
      flash[:notice] = 'Great success!'
      redirect '/'
    else
      flash[:error] = 'Login failed'
      render :new
    end
  end
  
  def delete
    reset_session
    flash[:notice] = 'Goodbye!'
    redirect '/'
  end
end
