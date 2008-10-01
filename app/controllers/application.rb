class Application < Merb::Controller
  def current_user
    (@user ||= User.find(session[:user_id]))
  end
  
  def reset_session
    session[:user_id] = nil
  end
end
