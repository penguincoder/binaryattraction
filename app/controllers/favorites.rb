class Favorites < Application
  before :logged_in?
  before :fetch_allowed_user, :only => [ :show ]
  only_provides :xml
  
  def show
    only_provides :html
    @photos = @user.favorite_photos
    render
  end
  
  def create
    raise NotAllowed unless request.xhr?
    @photo = Photo.find params[:id]
    pf = PhotoFavorite.new :photo_id => @photo.id, :user_id => current_user.id
    if pf.save
      render '', :status => 200
    else
      render '', :status => 403
    end
  end
  
  def delete
    raise NotAllowed unless request.xhr?
    pf = PhotoFavorite.find params[:id], :include => :user
    if pf.user == current_user and pf.destroy
      render '', :status => 200
    else
      render '', :status => 403
    end
  end
end
