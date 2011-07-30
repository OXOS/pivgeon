class UsersController < ApplicationController

  layout "application"
  
  def new
    @user = User.new
  end 

  def create
    @user = User.new params[:user]
    if @user.save
      redirect_to user_path(@user)
    else
      render :action => :new
    end
  end
    
  def show
    @message = "Congratulations, your account has been created."
  end
  
end
