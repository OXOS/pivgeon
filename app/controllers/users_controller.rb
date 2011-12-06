class UsersController < ApplicationController

  layout "application"

  before_filter :find_user, :only => [:confirm]
  
  def new
    @user = User.new
  end 

  def create
    @user = User.new params[:user]
    if @user.save
      flash[:notice] = "Your account has been created. We require you to activate your account by email, just click the link we have sent you."
      render :action => :show
    else
      render :action => :new
    end
  end
    
  def show    
  end

  def confirm
    if @user.activate!
      flash[:notice] = "Your account has been activated"
    else
      flash[:notice] = "Sorry. Your account hasn't been activated."
    end
  end

  protected

  def find_user
    unless @user = User.inactive.find_by_activation_code(params[:id])
      render('public/404.html', :layout=>false, :status => 404)
    end
  end

end