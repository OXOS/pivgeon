class User < ActiveRecord::Base
  validates(:name,  :presence => true)
  validates(:token, :presence => true)
  validates(:email, :presence => true, :uniqueness => true)
  
  
  def self.parse_message(message)
    mail = Mail.new(message)
    name,token = parse_subject(mail.subject)
    {}.tap do |params| 
      params[:email] = mail.from
      params[:name]  = name
      params[:token] = token
    end 
  end
  
  protected    
  
  def self.parse_subject(subject)
    subject.split(",")
  end

end
