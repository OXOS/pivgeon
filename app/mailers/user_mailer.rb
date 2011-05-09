class UserMailer < ActionMailer::Base
  default :from => "pivgeon@pivgeon.com"
  layout "application"
  helper :application
  
  def created_notification(user,error_message=nil)
    @activation_link = user.activation_code
    mail(:to => user.email, :from => from, :reply_to => "pivgeon@pivgeon.com", :subject => "#{APP_NAME}: new user confirmation")
  end
  
  def not_created_notification(user,error_message=nil)
    @email = ( user.is_a?(User) ? user.email : user.from.first )
    @user = user
    @error_message = error_message
    mail(:to => @email, :from => from, :reply_to => "pivgeon@pivgeon.com", :subject => "#{APP_NAME}: create new account error")
  end
  
  def from()
    %{"PivGeon" <pivgeon@pivgeon.com>}
  end
  
end
