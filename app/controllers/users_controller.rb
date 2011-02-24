class UsersController < ApplicationController
  
  def confirm
    @user = User.find_by_activation_code(params[:id])
    if @user.activate!
      render(:nothing=>true)
    else
      render(:nothing=>true, :status=>403)
    end
  end
  
end
