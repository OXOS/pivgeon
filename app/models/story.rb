class Story < HyperactiveResource
  
  self.site = "http://www.pivotaltracker.com/services/v3/projects/:project_id"
  self.columns = [:story_type, :name, :requested_by, :owned_by, :description, :project_name, :owner_email]  
  self.belong_tos = [:user]
  self.skip_to_xml_for = [:user_id, :project_name, :owner_email]
  
  include Pivgeon::Notification
  add_notifier(StoryMailer,"created_notification")
  
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
  
  def project()
    @project || Project.find_project_by_name(project_name,user.token)
  end
  
  def owner()
    _project = project()
    return nil unless _project

    memberships = _project.memberships
    return nil if memberships.blank?
    
    memberships.select{|m| m.person.email == owner_email}.first 
  end
  
  def url()
    "https://www.pivotaltracker.com/story/show/#{self.id}"
  end

  protected
  
  def before_validate
    self.owned_by = owner.person.name
    self.prefix_options[:project_id] = project.id
  end
  
end