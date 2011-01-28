class Story < ActiveResource::Base
  self.site = "http://www.pivotaltracker.com/services/v3/projects/147449/"
  
  attr_accessor :story_type, :name, :requested_by, :owned_by
  
  def self.create(attrs = {})
    token = attrs.delete(:token)
    set_token(token)
    super(attrs)
  end
  
  def self.parse_message(message)
    mail = Mail.new(message)
    user_from = find_user(mail.from.first)
    user_to = find_user(mail.to.first)
    {}.tap do |params| 
      params[:story_type]   = "chore"
      params[:name]         = mail.subject
      params[:requested_by] = (user_from ? user_from.name : nil)
      params[:owned_by]     = (user_to ? user_to.name : nil)
      params[:token]        = (user_from ? user_from.token : nil)
    end 
  end
  
  protected
  
  def self.find_user(email)
    User.find_by_email(email)
  end

  def self.set_token(token)
    self.headers['X-TrackerToken'] = token
  end
    
end