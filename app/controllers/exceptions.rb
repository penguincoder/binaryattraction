class Exceptions < Application
  
  # handle NotFound exceptions (404)
  def not_found
    do_your_render_thing
  end

  # handle NotAcceptable exceptions (406)
  def not_acceptable
    do_your_render_thing
  end
  
  private
  
  def do_your_render_thing
    if request.xhr?
      render :format => :html, :layout => false
    else
      render :format => :html
    end
  end

end