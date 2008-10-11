class Sessions < Application
  def index
    redirect '/'
  end
  
  def new
    render
  end
  
  def create
    user = User.find_by_user_name params[:user_name]
    if user and user.authenticated_against?(params[:password])
      session[:user_id] = user.id
      if request.xhr?
        render '', :status => 200
      else
        flash[:notice] = 'Great success!'
        redirect '/'
      end
    else
      if request.xhr?
        render '', :status => 401
      else
        flash.now[:error] = 'Login failed'
        render :new
      end
    end
  end
  
  def delete
    reset_session
    if request.xhr?
      render '', :status => 200
    else
      flash[:notice] = 'Goodbye!'
      redirect '/'
    end
  end
end
