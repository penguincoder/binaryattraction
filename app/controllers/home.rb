class Home < Application
  def index
    render
  end
  
  def acceptable_use
    render
  end
  
  def hall_of_fame
    @top_oneness = Photo.find :all, :order => 'oneness DESC, id DESC', :limit => 10, :conditions => 'oneness > 0 AND facebook_id IS NULL'
    render
  end
  
  def disclaimer
    render
  end
end
