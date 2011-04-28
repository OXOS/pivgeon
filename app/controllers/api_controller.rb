class ApiController < ApplicationController
  skip_before_filter :verify_authenticity_token  
  
  before_filter :parse_message
  before_filter :find_user
  before_filter :validate_subject  
  before_filter :find_story_owner
  
  def create      
    handle_exception do     
      if direct_sent_to_cloudmailin?(@message)
        create_user(@message)
      else
        create_story(@message)
      end
    end
  end
  
  
  protected
    
  def create_user(message)    
    attrs = User.parse_message(message)  
    @user = User.find_or_build(attrs)      
    @user.save!
    render_and_send_notification()
  end
  
  def create_story(message)    
    attrs = {:user_id=>@user.id,:owned_by=>@owner.person.name,:project_id=>@project.id,:name=>@parsed_subject[:subject],:story_type=>"chore",:description=>params[:plain]}   
    Story.token = @user.token    
    @story = Story.new(attrs)
    @story.save!
    render_and_send_notification()    
  end
  
  def direct_sent_to_cloudmailin?(message)
    return message.to.first == CLOUDMAILIN_EMAIL_ADDRESS
  end
  
  def parse_message
      @message = Mail.new(params[:message])
  end
  
  def validate_subject
    handle_exception do       
      unless direct_sent_to_cloudmailin?(@message)
        raise(ArgumentError) unless Story.valid_subject_format?(@message.subject)
      end
    end
  end
  
  def find_user
    handle_exception do
      unless direct_sent_to_cloudmailin?(@message)
        @user = User.active.find_by_email(@message.from.first)
        raise(SecurityError) if @user.blank?
      end
    end
  end
  
  def find_story_owner
    handle_exception do
      unless direct_sent_to_cloudmailin?(@message)
        @parsed_subject = Story.parse_subject(@message.subject)
        @project = Project.find_project_by_name(@parsed_subject[:project_name],@user.token)
        raise(ArgumentError) if @project.blank?

        @owner = Story.find_owner(@message.to.first,@project)
        raise(ArgumentError) if @owner.blank?
      end
    end
  end  
  
end
