class User < ActiveRecord::Base
  validates(:token, :presence => true)
  validates(:email, :presence => true, :uniqueness => true)
  
  
  def self.parse_message(message)
    name,token = parse_subject(message.subject)
    {}.tap do |params| 
      params[:email] = message.from.first
      params[:token] = token
    end 
  end
  
  protected    
  
  def self.parse_subject(subject)
    subject.split(",")
  end

end
