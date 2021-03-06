class Application < Merb::Controller
  def index
    redirect '/'
  end
  
  def current_user
    if session[:user_id]
      (@_user ||= User.find(session[:user_id]))
    else
      (cookies[:anonymous_id] ||= session.session_id)
    end
  end
  
  def logged_in?
    !session[:user_id].nil?
  end
  
  def administrator?
    logged_in? and current_user and current_user.administrator?
  end
  
  def valid_anonymous_user?
    !session[:validated_anonymous_user].nil?
  end
  
  def valid_anonymous_user!
    session[:validated_anonymous_user] = true
  end
  
  def reset_session
    session[:user_id] = nil
  end
  
  def get_photo_version(width, height)
    key = "photo_#{@photo.id}_#{width}_#{height}"
    img = Cache.get(key)
    
    File.open("#{@photo.base_directory}/#{@photo.filename}", "r") do |f|
      img = Magick::Image.from_blob(f.read).first.resize_to_fit(width, height)
      Cache.put(key, img)
    end if img.nil?
    
    img
  end
  
  def fetch_allowed_user
    @user = if administrator?
      User.find_by_user_name params[:id]
    elsif logged_in? and params[:id] != current_user.user_name
      raise NotAcceptable
    else
      current_user
    end
    raise NotFound if @user.nil?
  end
end
