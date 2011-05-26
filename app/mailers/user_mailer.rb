class UserMailer < ActionMailer::Base
  default :from => "pivgeon@pivgeon.com"
  layout "application"
  helper :application
  
  def created_notification(user,error_message,reference_message_id)
    @activation_link = user.activation_code
    set_reference_message_id(reference_message_id)
    mail(:to => user.email, :from => from, :reply_to => "pivgeon@pivgeon.com", :subject => "#{APP_NAME}: new user confirmation")
  end
  
  def not_created_notification(user,error_message,reference_message_id)
    @email = ( user.is_a?(User) ? user.email : user.from.first )
    @user = user
    @error_message = error_message
    set_reference_message_id(reference_message_id)
    mail(:to => @email, :from => from, :reply_to => "pivgeon@pivgeon.com", :subject => "#{APP_NAME}: create new account error")
  end
  
  def from()
    %{"#{APP_NAME}" <pivgeon@pivgeon.com>}
  end
  
  def set_reference_message_id(message_id)
    headers["In-Reply-To"] = message_id if message_id
  end
  
end
