class UserMailer < ActionMailer::Base
  default :from => "geepivomailin@example.com"
  layout "application"
  helper :application
  
  def registration_confirmation(user)
    @activation_link = user.activation_code
    mail(:to => user.email, :subject => "GeePivoMailin: new user confirmation")
  end
  
  def not_created_notification(user)
    @user = user
    mail(:to => user.email, :subject => "GeePivoMailin: create new account error")
  end
  
end
