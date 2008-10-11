class Photos < Application
  before :logged_in?, :only => [ :new, :create, :delete ]
  before :administrator?, :only => [ :delete ]
  before :make_photo, :only => [ :new, :create ]
  before :fetch_photo, :only => [ :show, :delete, :thumbnail ]
  
  def index
    @page = params[:page].to_i
    per_page = 24
    @page_count = (Photo.count(:id).to_f / per_page.to_f).ceil
    @photos = Photo.find :all, :order => 'id DESC', :limit => per_page, :offset => (per_page * @page)
    if request.xhr?
      partial 'photos/photo_browser'
    else
      render
    end
  end
  
  def show
    render
  end
  
  def new
    render
  end
  
  def create
    if @photo.save
      flash[:notice] = 'Great success'
      redirect url(:photo, @photo)
    else
      render :new
    end
  end
  
  def delete
    raise NotAcceptable unless request.xhr?
    if current_user and current_user.administrator?
      render
    else
      redirect '/'
    end
  end
  
  def thumbnail
    if @photo.exist?
      w = params[:width].to_i
      w = @photo.width if w == 0 or w > @photo.width
      h = params[:height].to_i
      h = @photo.height if h == 0 or h > @photo.height
      w = h if h > w
      send_data get_photo_version(w, w).to_blob, :filename => @photo.filename, :disposition => 'inline', :type => @photo.content_type
    else
      send_file Merb.root + '/public/images/image-missing.png', :disposition => 'inline'
    end
  end
  
  protected
  
  def make_photo
    @photo = Photo.new params[:photo]
  end
  
  def fetch_photo
    @photo = Photo.find params[:id]
    raise NotFound unless @photo
  end
end
