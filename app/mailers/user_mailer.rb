class UserMailer < ActionMailer::Base
  default :from => "pivgeon@pivgeon.com"
  layout "mailer"
  helper :application
  
  def created_notification(user,error_message,options={})
    @activation_link = user.activation_code
    reference_message_id,received_message_subject = parse_options(options)
    set_reference_message_id(reference_message_id)
    mail(:to => user.email, :from => from, :reply_to => "pivgeon@pivgeon.com", :subject => "Re: #{received_message_subject}")
  end
  
  def not_created_notification(user,error_message,options={})
    @email = ( user.is_a?(User) ? user.email : user.from.first )
    @user = user
    @error_message = error_message
    reference_message_id,received_message_subject = parse_options(options)
    set_reference_message_id(reference_message_id)
    mail(:to => @email, :from => from, :reply_to => "pivgeon@pivgeon.com", :subject => "Re: #{received_message_subject}")
  end
  
  def from()
    %{"#{APP_NAME}" <#{APP_URL}>}
  end
  
  def set_reference_message_id(message_id)
    headers["In-Reply-To"] = message_id if message_id
  end
  
  def parse_options(options)
    [options[:message_id],options[:message_subject]]   
  end
  
end
