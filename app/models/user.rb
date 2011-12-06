class User < ActiveRecord::Base
  validates(:email, :presence => {:message => "Email can't be blank"}, :uniqueness => {:message => "Email address is already taken",:on=>:create})
  validates :email, :email_format => {:message => 'Email is incorrect'}, :unless => Proc.new{|u| u.email.blank? }
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
    return if self.token.blank?
    
    uri = URI.parse("http://www.pivotaltracker.com")
    http = Net::HTTP.new(uri.host,uri.port)
    response = http.request(Net::HTTP::Get.new("/services/v3/projects",{"X-TrackerToken" => self.token}))
    
    self.errors.add(:token, "Token is invalid") if response.code.to_s == "401"
  end

  def generate_activation_code
    self.activation_code = (0..16).map{ rand(36).to_s(36) }.join
  end
    
end
