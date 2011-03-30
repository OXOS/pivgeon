class Story < HyperactiveResource
  self.site = "http://www.pivotaltracker.com/services/v3/projects/:project_id"
  
  self.columns = [:story_type, :name, :requested_by, :owned_by, :description  ]  
  
  validates(:name, :presence=>true)
  validates(:owned_by, :presence=>true)  
  
  def self.parse_subject(subject)
    match = subject.match(/^\s*\[(.+?)\](\s*Re:\s*|\s*re:\s*|\s*RE:\s*|\s*Fwd:\s*|\s*FWD:\s*|\s*fwd:\s*|\s*PD:\s*)?(.+)/)
    {}.tap do |subject|
      subject[:project_name] = match[1]
      subject[:subject] = match[3]      
    end    
  end
  
  def self.valid_subject_format?(subject)
    !subject.match(/^\s*\[.+?\].+/).blank?
  end
   
  def self.token()
    self.headers['X-TrackerToken']
  end
  
  def self.token=(token)
    self.headers['X-TrackerToken'] = (token ? token : "")
  end
  
  def self.find_owner(owner_email, project)
    memberships = project.memberships
    if memberships.count > 0
      member = memberships.select{|m| m.person.email == owner_email}.first    
      member
    else
      nil
    end    
  end
  
  def owned_by=(owner)
    self.attributes["owned_by"] = owner
    super(owner)
  end
end