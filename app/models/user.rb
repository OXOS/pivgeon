class User < ActiveRecord::Base
  
  before_validation(:generate_activation_code)
  before_create(:send_registration_confirmation)  
  
  scope :active, where(:status => "1")
  scope :inactive, where(:status => "0")
  
  validates(:email, :presence => true)
  validates(:email, :uniqueness => {:message => "There already exists an user account registered for this email address"}, :on=>:create)  
  validates(:activation_code, :presence => true, :on => :create)
  validate :validate_token
  
  after_validation(:send_notifications)
  
  def self.parse_message(message)
    {}.tap do |params| 
      params[:email] = message.from.first
      params[:token] = message.subject
    end 
  end
  
  def self.find_or_create_and_send_email(attrs={})
    if user = User.inactive.find_by_email(attrs[:email])
      user.send_registration_confirmation
      user
    else
      create(attrs)
    end
  end
  
  def send_registration_confirmation
    UserMailer.registration_confirmation(self).deliver
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
  
  def send_notifications
    return if self.errors.empty?
    UserMailer.not_created_notification(self).deliver
  end

  def generate_activation_code
    self.activation_code = (0..16).map{ rand(36).to_s(36) }.join
  end
      
end
