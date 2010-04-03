class UsersController < ApplicationController

  before_filter :login_required, :only => ['change_password']
  before_filter :login_as_api, :only => ['app_login']
  before_filter :set_cache_buster

  caches_page :welcome, :features, :faq, :contact

  def welcome
  end

  def features;end;
  def faq; end;
  def contact; end;

  def signup
    @user = User.new(params[:user])
    if @user.save
       Category.create_basic_category(@user.id)
       session[:user_id] = User.authenticate(@user.email,@user.password)
       puts session[:user_id]
       flash[:message] = "Signup successful"
       Notifier.deliver_welcome_message(@user.email)
       redirect_to :controller => "expenses", :action => "index"          
    else
      flash[:message] = "Signup unsuccessful"
    end
  end

  def login
    if request.post?
      if session[:user_id] = User.authenticate(params[:user][:email], params[:user][:password])
        flash[:message]  = "Welcome to Sillarai."
        redirect_to_stored
      else
        redirect_to "/users/welcome"
        flash[:message] = "Login unsuccessful"
      end
    end
  end

  def app_login
    session_id = Digest::SHA1.hexdigest(Time.now.to_s + rand(12341234).to_s)[1..32]
    if current_api_user.update_attribute(:mob_session_id, session_id)
      render :text => current_api_user.mob_session_id, :layout => false
    else
      render :text => "Login Failed", :layout => false
    end
  end


  
  def logout
    session[:user_id] = nil
    flash[:message] = 'Logged out'
    redirect_to :action => 'welcome'
  end

  def change_email
    email = params[:email]
    user = User.find_by_email(email)
    if not user
       puts current_user.email
      if current_user.update_attribute(:email,email)
        puts current_user.email
        flash[:message] = "Email address changed. "
      else
        flash[:message] = "Problem in saving mail address."
      end
    else
      flash[:message] = "Email address already in use."
    end
      redirect_to "/users/settings"
  end

  def forgot_password
    u= User.find_by_email(params[:user][:email])
    if u and u.send_new_password
      flash[:message]  = "A new password has been sent by email."
      redirect_to :action=>'welcome'
    else
      flash[:message]  = "Couldn't send password"
    end
  end
  
  def change_password
    @user = current_user
    if User.authenticate(current_user.email,params[:user][:current_password])                      
      @user.update_attributes(:password=>params[:user][:password], :password_confirmation => params[:user][:password_confirmation])
      if @user.save
        flash[:message]="Password Changed"
        redirect_to "/users/settings"
      end
    else
      flash[:message] = " Please enter the correct password"
      redirect_to "/users/settings"
    end
  end

  def contact_me
    name = params[:contact][:name]
    email = params[:contact][:email]
    comment = params[:contact][:comments]
    web = params[:contact][:website]
    Notifier.deliver_contact_details(name,email,comment,web)
    redirect_to "/users/welcome"
  end

  def settings
    @user = current_user
    render :layout => false
  end

  def usage_survey
    d = params[:use_data]
    val = 0
    if d == "yes"
      val = 1
    else
      val =0
    end
     
    if current_user.update_attribute("data_usage",val)
        flash[:message] = " Updated successfully. "
 
    else
        flash[:message] = " Not updated. "
    
    end
      redirect_to "/users/settings"
  end
  
  def bayes_preference
    d = params[:bayes]
    val = 0
    if d == "yes"
      val = 1
    else
      val =0
    end
     
    if current_user.update_attribute("use_bayes",val)
        flash[:message] = " Updated successfully. "
 
    else
        flash[:message] = " Not updated. "
    
    end
      redirect_to "/users/settings"
  end

end
