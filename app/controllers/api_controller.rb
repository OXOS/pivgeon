class ApiController < ApplicationController
  skip_before_filter :verify_authenticity_token  
    
  before_filter :parse_message
  before_filter :find_user  
  before_filter :validate_and_parse_subject
  
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
    attrs = {:user_id=>@user.id,:owner_email=>@message.to.first,:project_name=>@parsed_subject[:project_name],:name=>@parsed_subject[:subject],:story_type=>"chore",:description=>params[:plain]}   
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
  
  def validate_and_parse_subject
    handle_exception do       
      unless direct_sent_to_cloudmailin?(@message)        
        raise(ArgumentError) unless Story.valid_subject_format?(@message.subject)
        @parsed_subject = Story.parse_subject(@message.subject)
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
  
end
