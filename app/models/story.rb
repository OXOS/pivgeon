class Story < ActiveResource::Base
  self.site = "http://www.pivotaltracker.com/services/v3/projects/147449/"
  self.headers['X-TrackerToken'] = 'eebe7dd0892e7156266362498942a8a2'
  
  attr_accessor :story_type, :name, :requested_by, :owned_by
  
  # TODO: add validations - currently commented out due to strange situation with validation of ActiveResource object attributes.
  #validates_presence_of :story_type, :name, :requested_by, :owned_by

  def self.create_story message
    instance_params = self.parse_incoming_message(message)
    begin
      story = create(instance_params)
      return !story.new?
		rescue ActiveResource::UnauthorizedAccess
			return false
		end
  end
  
  protected
  
  def self.parse_incoming_message message
    require 'mail'
    mail = Mail.new(message)
    {:story_type=>"chore", :name=>mail.subject, :requested_by=>"daniel", :owned_by=>"daniel"}
  end
  
end