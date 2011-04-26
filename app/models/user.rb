class User < ActiveRecord::Base
  
  include Pivgeon::Notification
  add_notifier(UserMailer,"created_notification")
  
  validates(:email, :presence => true, :uniqueness => {:message => "There already exists an user account registered for this email address",:on=>:create})
  validates(:activation_code, :presence => true, :on => :create)
  validate :validate_token
  
  before_validation(:generate_activation_code)    
  
  scope :active, where(:status => "1")
  scope :inactive, where(:status => "0")
         
  def self.parse_message(message)
    {}.tap do |params| 
      params[:email] = message.from.first
      params[:token] = message.subject
    end 
  end
  
  #TODO: should it update attrs for found user?
  def self.find_or_build(attrs={})
    if user = User.inactive.find_by_email(attrs[:email])
      user.attributes = attrs
      user
    else
      new(attrs)
    end
  end
  
  def activate!
    self.status = true
    self.save
  end
  
  protected
  
  def validate_token
    begin
      Project.token = self.token
      Project.find(:all)
    rescue
      self.errors.add(:token, "The given token '#{self.token}' is invalid")
    end
  end
    
  def generate_activation_code
    self.activation_code = (0..16).map{ rand(36).to_s(36) }.join
  end
      
end
