class Story < ActiveResource::Base
  self.site = "http://www.pivotaltracker.com/services/v3/projects/147449/"
  
  attr_accessor :story_type, :name, :requested_by, :owned_by, :description
  
  def self.create(message)
    params = parse_message_and_set_token(message)
    super(params)
  end
  
#  protected
  
  def self.parse_message_and_set_token(attrs={})
    mail = Mail.new(attrs['message'])
    set_token(mail.from.first)
    {}.tap do |params| 
      params[:story_type]   = "chore"
      params[:name]         = mail.subject      
      params[:description]  = attrs['plain']
      params[:requested_by] = get_user_name(mail.from.first)
      params[:owned_by]     = get_user_name(mail.to.first)
    end 
  end
  
  def self.get_user_name(email)
    if user = GEEPIVO_USERS[email]
      return user['name']
    else
      return ""
    end
  end
  
  # FIXME: this is not best way to set token. 
  # token should be specified while creating new instance by setting header or as a query param
  # unfortunately rails does not provide it yet 
  def self.set_token user_email    
    Rails.logger.info "############################ calling set_token(#{user_email})"
    if user = GEEPIVO_USERS[user_email]      
      Rails.logger.info "############################ --------------- set self.headers['X-TrackerToken'] = #{user['token']}"
      self.headers['X-TrackerToken'] = user['token'] if user['token']
    else
      Rails.logger.info "############################ --------------- set self.headers['X-TrackerToken'] = ''"
      self.headers['X-TrackerToken'] = ""
    end
  end
    
end