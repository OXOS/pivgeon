class UsersController < ApplicationController
  
  def confirm
    @user = User.find_by_activation_code(params[:id])
    if @user.activate!
      @message = "Your account has been activated"
    else
      @message = "Sorry. Your account hasn't been activated."
    end
  end
  
end
