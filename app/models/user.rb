class User < ActiveRecord::Base
  
  include Pivgeon::Notification
  add_notifier(UserMailer,"created_notification")
  
  validates(:email, :presence => true, :uniqueness => {:message => "There already exists an user account registered for this email address",:on=>:create})
         
  def self.parse_message(message)
  end
  
  def self.find_or_build(attrs={})
    if user = User.inactive.find_by_email(attrs[:email])
      user.attributes = attrs
      user
    else
      new(attrs)
    end
  end
  
  def activate!
  end
  
end
