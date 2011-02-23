class UserMailer < ActionMailer::Base
  default :from => "geepivomailin@example.com"
  
  def registration_confirmation(user)
    @activation_link = "http://geepivomailindev.heroku.com/users/confirm/#{user.activation_code}"
    mail(:to => user.email, :subject => "GeePivoMailin: registration confirmation")
  end
  
end
