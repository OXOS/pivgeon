class User < ActiveRecord::Base
  
  validates(:email, :presence => {:message => "Email can't be blank"}, :uniqueness => {:message => "Email address is already taken",:on=>:create})
  validates :email, :email_format => {:message => 'Email is incorrect'}
  validates(:token, :presence => {:message => "Token can't be blank"})
  validate :validate_token
        
  HUMAN_ATTRIBUTE_NAMES = {
    "token" => "Pivotal token:",
  }
 
  def self.human_attribute_name(*args)
    attr_name = HUMAN_ATTRIBUTE_NAMES[args[0].to_s]    
    return attr_name if attr_name    
    super
  end

  protected

  def validate_token
    begin
      Project.token = self.token
      Project.find(:all)
    rescue
      self.errors.add(:token, "Token is invalid")
    end
  end
    
end
