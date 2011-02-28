class ApiController < ApplicationController
  skip_before_filter :verify_authenticity_token  
  
  before_filter :parse_message
  before_filter :validate_subject
  before_filter :find_user
  before_filter :find_story_owner
  
  def create    
    if direct_sent_to_cloudmailin?(@message)
      create_user(@message)
    else
      create_story(@message)
    end
  end
  
  
  protected
    
  def create_user(message)    
    attrs = User.parse_message(message)      
    user = User.find_or_create_and_send_email(attrs)
    render_proper_status(user.new_record?)
  end
  
  def create_story(message)    
    attrs = {:owned_by=>@owner.person.name,:project_id=>@project.id,:name=>@parsed_subject[:subject],:story_type=>"chore",:description=>params[:plain]}   
    Story.token = @user.token    
    story = Story.create(attrs)
    render_proper_status(story.new?)     
  end
  
  def render_proper_status(new_record=true)
    if new_record      
      render(:text => "Invalid data", :status => 403)
    else
      render(:nothing => true)
    end 
  end
  
  def direct_sent_to_cloudmailin?(message)
    return message.to.first == CLOUDMAILIN_EMAIL_ADDRESS
  end
  
  def parse_message
    @message = Mail.new(params[:message])
  end
  
  def validate_subject
    unless direct_sent_to_cloudmailin?(@message)
      raise(ArgumentError) unless Story.valid_subject_format?(@message.subject)
    end
  end
  
  def find_user
    unless direct_sent_to_cloudmailin?(@message)
      @user = User.active.find_by_email(@message.from.first)
      raise(SecurityError) if @user.blank?
    end
  end
  
  def find_story_owner
    unless direct_sent_to_cloudmailin?(@message)
      @parsed_subject = Story.parse_subject(@message.subject)
      @project = Project.find_project_by_name(@parsed_subject[:project_name],@user.token)
      raise(ArgumentError) if @project.blank?

      @owner = Story.find_owner(@message.to.first,@project)
      raise(ArgumentError) if @owner.blank?
    end
  end
  
end
