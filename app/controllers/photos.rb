class Photos < Application
  before :logged_in?, :only => [ :new, :create, :destroy ]
  before :administrator?, :only => [ :destroy, :approve, :moderate ]
  before :make_photo, :only => [ :new, :create ]
  before :fetch_photo, :only => [ :show, :destroy, :thumbnail, :approve, :flag ]
  
  def index
    @page = params[:page].to_i
    per_page = 24
    @page_count = (Photo.count(:id, :conditions => 'facebook_id IS NULL').to_f / per_page.to_f).ceil
    @photos = Photo.find :all, :order => 'id DESC', :limit => per_page, :offset => (per_page * @page), :conditions => 'facebook_id IS NULL'
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
    @photo.user_id = current_user.id
    if @photo.save
      flash[:notice] = 'Great success'
      redirect url(:photo, @photo)
    else
      render :new
    end
  end
  
  def destroy
    raise NotAcceptable unless request.xhr?
    if @photo.destroy
      render '', :status => 200
    else
      render '', :status => 401
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
  
  def approve
    raise NotAllowed unless request.xhr?
    @photo.approved = true
    if @photo.save
      render '', :status => 200
    else
      render '', :status => 401
    end
  end
  
  def flag
    raise NotAllowed unless request.xhr?
    pf = PhotoFlag.new :photo_id => @photo.id, :user_id => current_user.id
    if pf.save
      render '', :status => 200
    else
      render '', :status => 401
    end
  end
  
  def moderate
    @photos = Photo.find :all, :order => "photo_flags_count DESC, id ASC", :conditions => [ 'approved = ?', false ]
    render
  end
  
  def by_email
    if request.post? and !params[:email].to_s.empty?
      redirect url(:action => :by_hash, :id => User.salted_string(params[:email]))
    else
      render
    end
  end
  
  def by_hash
    @photo_ids = Photo.find(:all, :select => 'id', :conditions => [ 'email_hash = ?', params[:id] ]).collect(&:id) rescue []
    @votes = Vote.find :all, :conditions => "photo_id IN (#{@photo_ids.join(',')})" rescue []
    if params[:id].to_s.empty? or @photo_ids.empty? or @votes.empty?
      redirect url(:action => :by_email)
    else
      render
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
