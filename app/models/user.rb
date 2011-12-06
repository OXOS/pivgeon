class User < ActiveRecord::Base
  validates(:email, :presence => {:message => "Email can't be blank"}, :uniqueness => {:message => "Email address is already taken",:on=>:create})
  validates :email, :email_format => {:message => 'Email is incorrect'}
  validates(:token, :presence => {:message => "Token can't be blank"})
  validates(:activation_code, :presence => true, :on => :create)
  validate :validate_token
  
  scope :active, where(:status => "1")
  scope :inactive, where(:status => "0")
        
  HUMAN_ATTRIBUTE_NAMES = {
    "token" => "Pivotal token:",
  }

  before_validation(:generate_activation_code)
  after_create(:send_activation_link)

  def self.human_attribute_name(*args)
    attr_name = HUMAN_ATTRIBUTE_NAMES[args[0].to_s]    
    return attr_name if attr_name    
    super
  end

  def activate!
    self.status = true
    self.save
  end

  def send_activation_link
    UserMailer.created_notification(self).deliver!
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

  def generate_activation_code
    self.activation_code = (0..16).map{ rand(36).to_s(36) }.join
  end
    
end
