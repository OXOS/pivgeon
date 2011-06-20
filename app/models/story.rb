class Story < PivotalItem
  
  self.site = "http://www.pivotaltracker.com/services/v3/projects/:project_id"
  self.columns = [:story_type, :name, :requested_by, :owned_by, :description, :project_name, :owner_email]  
  self.belong_tos = [:user]
  self.skip_to_xml_for = [:user_id, :project_name, :owner_email]
  
  HUMAN_ATTRIBUTE_NAMES = {
    "owned_by" => "A person",
    "name" => "Story name"
  }
  
  #GET_PROJECT_FROM_SUBJECT_REGEXP = /^\s*\[(.+?)\](\s*Re:\s*|\s*re:\s*|\s*RE:\s*|\s*Fwd:\s*|\s*FWD:\s*|\s*fwd:\s*|\s*PD:\s*)?(.+)/
  EMAIL_DETOKENIZE_REGEXP = /<(.*)>/
  
  include Pivgeon::Notification
  
  add_notifier(StoryMailer,"created_notification")
    
  validates(:name, :presence=>true)  
  
  def self.detokenize(email)
    result = email.match(EMAIL_DETOKENIZE_REGEXP)
    result ? result[1] : email
  end
  
  def self.get_project_and_story_name(subject,email)
    email = detokenize(email)
    project_name = if( email == "pivgeon@pivgeon.com" ) 
      ""
    else
      email.split('@').first
    end
    [project_name,subject]
  end
  
  def self.human_attribute_name(*args)
    attr_name = HUMAN_ATTRIBUTE_NAMES[args[0].to_s]    
    return attr_name if attr_name    
    super
  end

  def self.valid_subject_format?(subject)
    !subject.match(/^\s*\[.+?\].+/).blank?
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
  
  def set_default_attributes()
    self.story_type = "feature"
  end

  protected    
  
  #TODO: validations are not well done for activeresource so this is why it looks so ugly! 
  #It should be rewrite when it will be improved in next rails releases.
  
  def before_validate()
    self.owned_by = owner.person.name if owner
    self.prefix_options[:project_id] = project.id if project
    self.set_default_attributes()    
  end
  
  def validate()
    before_validate()
    errors[:project] << "'#{project_name}' that you try to create this story for does not exist." and raise(RecordNotSaved) if self.prefix_options[:project_id].blank?
    errors[:owned_by] << "that you try to assign to the story is not a project member." and raise(RecordNotSaved) if self.owned_by.blank?     
  end

  def self.mailer_class
    StoryMailer
  end
      
  
end
