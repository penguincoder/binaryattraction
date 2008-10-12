class Home < Application
  def index
    render
  end
  
  def acceptable_use
    render
  end
  
  def hall_of_fame
    @top_oneness = Photo.find :all, :order => 'oneness DESC, id DESC', :limit => 10, :conditions => 'oneness > 0'
    @top_voted = Photo.find :all, :order => 'votes_count DESC, id DESC', :limit => 10, :conditions => 'votes_count > 0'
    render
  end
  
  def disclaimer
    render
  end
end
