class User < ActiveRecord::Base
  validates(:token, :presence => true)
  validates(:email, :presence => true, :uniqueness => true)
  
  
  def self.parse_message(message)
    {}.tap do |params| 
      params[:email] = message.from.first
      params[:token] = message.subject
    end 
  end

end
