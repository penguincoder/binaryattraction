class Favorites < Application
  before :logged_in?
  
  def show
    @page = params[:page].to_i
    per_page = 24
    @page_count = (current_user.photo_favorites.count(:id).to_f / per_page.to_f).ceil
    @photos = current_user.favorite_photos.find :all, :order => 'id DESC', :limit => per_page, :offset => (per_page * @page)
    if request.xhr?
      partial 'photos/photo_browser'
    else
      render
    end
  end
  
  def create
    raise NotAcceptable unless request.xhr?
    @photo = Photo.find params[:photo_id] rescue nil
    pf = PhotoFavorite.new :photo_id => @photo.id, :user_id => current_user.id
    if pf.save
      render '', :status => 200
    else
      render '', :status => 403
    end
  end
  
  def destroy
    raise NotAcceptable unless request.xhr?
    pf = current_user.photo_favorites.detect do |f|
      f.photo_id == params[:id].to_i
    end
    if pf and pf.user_id == current_user.id and pf.destroy
      render '', :status => 200
    else
      render '', :status => 403
    end
  end
end
