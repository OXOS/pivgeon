class UserMailer < ActionMailer::Base
  default :from => "geepivomailin@example.com"
  layout "application"
  helper :application
  
  def created_for_creator(user,error_message=nil)
    @activation_link = user.activation_code
    mail(:to => user.email, :subject => "GeePivoMailin: new user confirmation")
  end
  
  def not_created_for_creator(user,error_message=nil)
    @email = ( user.is_a?(User) ? user.email : user.from.first )
    @user = user
    @error_message = error_message
    mail(:to => @email, :subject => "GeePivoMailin: create new account error")
  end
  
end
