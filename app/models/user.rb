class User < ActiveRecord::Base
  
  validates(:email, :presence => true, :uniqueness => {:message => "There already exists an user account registered for this email address",:on=>:create})
  validates(:activation_code, :presence => true, :on => :create)
  validate :validate_token
  
  before_validation(:generate_activation_code)
  before_create(:send_registration_confirmation)  
  after_validation(:send_notifications)
  
  scope :active, where(:status => "1")
  scope :inactive, where(:status => "0")
         
  def self.parse_message(message)
    {}.tap do |params| 
      params[:email] = message.from.first
      params[:token] = message.subject
    end 
  end
  
  def self.find_or_create_and_send_email(attrs={})
    if user = User.inactive.find_by_email(attrs[:email])
      if user.update_attributes(attrs)
        user.send_registration_confirmation
        return(user)
      else
        nil
      end
    else
      create(attrs)
    end
  end
  
  def send_registration_confirmation
    UserMailer.registration_confirmation(self).deliver
  end
  
  def send_notifications
    return if self.errors.empty?
    UserMailer.not_created_notification(self).deliver
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
