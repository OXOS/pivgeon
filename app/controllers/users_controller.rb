class UsersController < ApplicationController

  layout "application"
  
  def new
    @user = User.new
  end 

  def create
    @user = User.create params[:user]
    redirect_to user_path(@user)
  end
    
  def show
    @message = "Congratulations, your account has been created."
  end
  
end
