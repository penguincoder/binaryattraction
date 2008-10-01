module Merb
  module GlobalHelpers
    def logged_in?
      !session[:user_id].nil?
    end
    
    def error_messages(obj)
      if obj.errors.empty?
        nil
      else
        "<div id='model_errors'><ul>#{obj.errors.each_full { |msg| "<li>#{msg}</li>" }}</ul></div>"
      end
    end
  end
end
