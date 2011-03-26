class UserMailer < ActionMailer::Base
  default :from => "geepivomailin@example.com"
  
  def registration_confirmation(user)
    @activation_link = user.activation_code
    mail(:to => user.email, :subject => "GeePivoMailin: new user confirmation")
  end
  
end
