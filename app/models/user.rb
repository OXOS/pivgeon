class User < ActiveRecord::Base
  
  before_validation :generate_activation_code
  before_create :send_registration_confirmation
  
  validates(:token, :presence => true)
  validates(:email, :presence => true)
  validates(:email, :uniqueness => true, :on=>:create)  
  validates(:activation_code, :presence => true, :on => :create)
  
  def self.parse_message(message)
    {}.tap do |params| 
      params[:email] = message.from.first
      params[:token] = message.subject
    end 
  end
  
  protected

  def generate_activation_code
    self.activation_code = (0..16).map{ rand(36).to_s(36) }.join
  end
  
  def send_registration_confirmation
    self.activation_code = activation_code    
    UserMailer.registration_confirmation(self).deliver
  end
  
end
