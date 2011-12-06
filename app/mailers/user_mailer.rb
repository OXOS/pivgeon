class UserMailer < ActionMailer::Base
  default :from => CLOUDMAILIN_EMAIL_ADDRESS
  layout "mailer"
  helper :application

  def created_notification(user)
    @activation_code = user.activation_code
    mail(:to => user.email, :from => from, :reply_to => "pivgeon@pivgeon.com", :subject => "Pivgeon - new account activation.")
  end

  def from()
    %{"#{APP_NAME}" <#{CLOUDMAILIN_EMAIL_ADDRESS}>}
  end


end
