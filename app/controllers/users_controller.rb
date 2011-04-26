class UsersController < ApplicationController
  
  before_filter :find_user
  
  def confirm    
    if @user.activate!
      @message = "Your account has been activated"
    else
      @message = "Sorry. Your account hasn't been activated."
    end
  end
  
  protected
  
  def find_user
    unless @user = User.inactive.find_by_activation_code(params[:id])          
      render('public/404.html', :layout=>false, :status => 404)
    end
  end
  
end
