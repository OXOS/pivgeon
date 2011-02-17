class Story < HyperactiveResource
  self.site = "http://www.pivotaltracker.com/services/v3/projects/:project_id"
  
  attr_accessor :story_type, :name, :requested_by, :owned_by, :project_id, :description
  
  def self.parse_message(message)               
    {}.tap do |params| 
      params[:story_type]   = "chore"
      params[:name]         = message.subject.split(":")[1]
      params[:description]  = message.body.to_s
      params[:requested_by] = message.from.first
      params[:owned_by]     = message.to.first      
      params[:project_id]   = message.subject.split(":")[0]
    end 
  end
   
  def self.token()
    self.headers['X-TrackerToken']
  end
  
  def self.token= token
    self.headers['X-TrackerToken'] = (token ? token : "")
  end
  
  protected
  
  def find_user_token(email)
    User.find_by_email(email).try(:token)
  end

  def set_token()
    user_email = self.attributes.delete('requested_by')
    token = self.find_user_token(user_email)
    Story.token = token
  end
  
  def set_story_owner()
    Membership.headers['X-TrackerToken'] = Story.token
    memberships = Membership.find(:all,:params=>{:project_id=>self.project_id})    
    member = if memberships.blank?
      ""
    else
      member = memberships.select{|m| m.person.email == self.owned_by}.first
      member.blank? ? "" : member.try(:person).try(:name)
    end
    self.attributes['owned_by']= member
  end
    
  def before_save
    set_token()
    set_story_owner()
  end
end