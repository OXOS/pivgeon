class Story < HyperactiveResource
  self.site = "http://www.pivotaltracker.com/services/v3/projects/:project_id"
  
  self.columns = [:story_type, :name, :requested_by, :owned_by, :description  ]  
  
  validates(:name, :presence=>true)
  validates(:owned_by, :presence=>true)  
  
  def self.parse_message(message)    
    raise(ArgumentError) unless valid_subject_format?(message.subject)
    parsed_subject = Story.parse_subject(message.subject)
    {}.tap do |params| 
      params[:story_type]   = "chore"
      params[:name]         = parsed_subject[:name]
      params[:description]  = message.body.to_s
      params[:requested_by] = message.from.first
      params[:owned_by]     = message.to.first      
      params[:project_id]   = parsed_subject[:project_id]
    end 
  end
  
  def self.parse_subject(subject)
    match = subject.match(/(^\d+):(Re:|re:|RE:|Fwd:|FWD:|fwd:)?(.+)/)
    {}.tap do |subject|
      subject[:project_id] = match[1]
      subject[:name] = match[3]      
    end    
  end
  
  def self.valid_subject_format?(subject)
    !subject.match(/^\d+:.+/).blank?
  end
   
  def self.token()
    self.headers['X-TrackerToken']
  end
  
  def self.token=(token)
    self.headers['X-TrackerToken'] = (token ? token : "")
  end    
  
  def find_user_by_email(email)
    user = User.active.find_by_email(email)
    raise(SecurityError) if user.blank?
    user
  end
  
  # get to pivotaltracker for all project memberships
  def get_memberships_for_project
    Membership.token = Story.token
    Membership.find(:all,:params=>{:project_id=>self.prefix_options[:project_id]})    
  end
  
  def owned_by=(owner)
    self.attributes["owned_by"] = owner
    super(owner)
  end
  
  protected
  
  def set_token()
    user_email = self.attributes.delete('requested_by')
    user = find_user_by_email(user_email)
    Story.token = user.token
  end
  
  def set_story_owner()        
    memberships = get_memberships_for_project()    
    unless memberships.blank? 
      member = memberships.select{|m| m.person.email == self.owned_by}.first    
      member = member.try(:person).try(:name) unless member.blank?
      self.owned_by = member
    else
      self.owned_by = nil
    end    
  end
    
  def before_save
    set_token()
    set_story_owner()
  end
end