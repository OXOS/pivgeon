class Story < ActiveResource::Base
  self.site = "http://www.pivotaltracker.com/services/v3/projects/147449/"
  self.headers['X-TrackerToken'] = 'eebe7dd0892e7156266362498942a8a2'
  
  attr_accessor :story_type, :name, :requested_by, :owned_by
  
  # TODO: add validations - currently commented out due to strange situation with validation of ActiveResource object attributes.
  #validates_presence_of :story_type, :name, :requested_by, :owned_by
  
  def self.create(message)
    message = parse_incoming_message(message)
    super(message)
  end
  
  protected
  
  def self.parse_incoming_message(message)
    mail = Mail.new(message)
    {:story_type=>"chore", :name=>mail.subject, :requested_by=>get_user_name(mail.from.first), :owned_by=>get_user_name(mail.to.first)}
  end
  
  def self.get_user_name(email)
    if user = GEEPIVO_USERS[email]
      return user['name']
    else
      return ""
    end
  end
  
end