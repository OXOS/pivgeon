class Notifier < ActionMailer::Base
  default :from => CLOUDMAILIN_EMAIL_ADDRESS
  layout "mailer"
  helper :application
  
  def unauthorized_access(message,message_id)    
    @email = message.from    
    set_reference_message_id(message_id)
    mail(:to => @email, :from => from, :reply_to => CLOUDMAILIN_EMAIL_ADDRESS, :subject => "Re: #{message.subject}")
  end
  
  protected
  
  def from()
    %{"#{APP_NAME}" <#{CLOUDMAILIN_EMAIL_ADDRESS}>}
  end
  
  def set_reference_message_id(message_id)
    headers({"In-Reply-To" => message_id.to_s, "References" => message_id.to_s}) if message_id
  end
end
