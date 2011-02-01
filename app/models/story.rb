class Story < HyperactiveResource
  self.site = "http://www.pivotaltracker.com/services/v3/projects/147449/"
  
  attr_accessor :story_type, :name, :requested_by, :owned_by, :project_id
  
  def self.create(attrs = {})
    token = attrs.delete(:token)
    set_token(token)    
    super(attrs)
  end
  
  def self.parse_message(message)           
    project_id = "147449" # this should be replaced by getting project_id from email
    {}.tap do |params| 
      params[:story_type]   = "chore"
      params[:name]         = message.subject            
      params[:description]  = message.body
      params[:owned_by]     = message.to.first
      params[:token]        = find_user_token(message.from.first),
      params[:project_id]   = project_id  
    end 
  end
  
  def self.token()
    self.headers['X-TrackerToken']
  end
  
  protected
  
  def self.find_user_token(email)
    User.find_by_email(email).try(:token)
  end

  def self.set_token(token)
    self.headers['X-TrackerToken'] = (token ? token : "")
  end
  
  def set_story_owner()
    Membership.headers['X-TrackerToken'] = Story.token
    memberships = Membership.find(:all,:params=>{:project_id=>self.project_id})
    member = memberships.each.select{|m| m.person.email == self.owned_by}.first
    self.attributes['owned_by'] = member.try(:person).try(:name)
  end
  
  def before_save
    set_story_owner()
  end
    
end