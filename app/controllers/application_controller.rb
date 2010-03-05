# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password
 
 def login_required
      if session[:user_id]
        return true
      end
      flash[:warning]='Please login to continue'
      session[:return_to]=request.request_uri
      redirect_to :controller => "users", :action => "welcome"
      return false 
  end

  def login_as_api
      authenticate_or_request_with_http_basic do |u,p|
        @api_user = User.authenticate u,p
      end
  end
  
  def current_api_user
     User.find_by_id(@api_user)
  end

  def verify_api_user(app_id)
     User.find_by_mob_session_id(app_id)
  end

  def current_user
    User.find_by_id(session[:user_id])
  end
  
  def redirect_to_stored
    if return_to = session[:return_to]
      session[:return_to]=nil
      redirect_to return_to
    else
      redirect_to :controller=>'expenses', :action=>'index'
    end
  end
  
  def set_cache_buster
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end

  
  def get_categories
    @categories = current_user.categories
  end

  protected
  @api_user

end
