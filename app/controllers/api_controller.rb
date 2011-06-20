class ApiController < ApplicationController
  skip_before_filter :verify_authenticity_token  
    
  before_filter :parse_message
  before_filter :find_user  
  before_filter :find_project_and_story_name
  
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
    attrs = {:user_id=>@user.id,
             :owner_email=>@message.to.first,
             :project_name=>@project_name,
             :name=>@story_name,             
             :description=>params["text"]}
    Story.token = @user.token    
    @story = Story.new(attrs)    
    @story.save!
    render_and_send_notification()    
  end
  
  def direct_sent_to_cloudmailin?(message)
    return message.to.first == CLOUDMAILIN_EMAIL_ADDRESS
  end
  
  def parse_message
    Rails.logger.info("\n\n#{params["headers"]}\n\n")
    @mesage = Mail.new(params["headers"])
    Rails.logger.info("\n\n#{@message.inspect}\n\n")
    #@message = OpenStruct.new(:to=>[params["to"]],:from=>[params["from"]],:body=>params["text"],:subject=>params["subject"])
  end
  
  def find_project_and_story_name
    handle_exception do       
      unless direct_sent_to_cloudmailin?(@message)        
          @project_name,@story_name = Story.get_project_and_story_name(@message.subject,params[:to])
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
  
  protected
  
  def handle_exception(&block)
    headers["Content-type"] = "text/plain" 
    begin
      block.call      
    rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid, RecordNotSaved
      render_and_send_notification()
    rescue ActiveResource::UnauthorizedAccess, SecurityError
      render_and_send_notification("Unauthorized access")
    rescue ArgumentError
      render_and_send_notification("Invalid data")
    rescue ActiveResource::ServerError, ActiveResource::TimeoutError
      render_and_send_notification("Server error")
    rescue => error
      render_and_send_notification("Unknown error")
    end  
  end
      
  def render_and_send_notification(error_message=nil)
    error_message.blank? ? send_notification_for_object() : send_notification_for_exception(error_message)
    render(:text => "Success", :status => 200)
  end   
  
  def send_notification_for_object()
    _class,_object = get_class_and_object()
    _class.send_notification(_object,nil,:message_id => @message['Message-ID'], :message_subject => @message.subject)
  end
  
  def send_notification_for_exception(error_message)
    _class,_object = get_class_and_object()
    _class.send_notification(@message,error_message,:message_id => @message['Message-ID'], :message_subject => @message.subject)
  end
  
  def get_class_and_object()
    direct_sent_to_cloudmailin?(@message) ? [User,@user] : [Story,@story]    
  end

  rescue_from(Exception) do |e|
	#TODO: consider what to do when mailer raises error but story/user is created
	render(:text => "Success", :status => 200)
  end

end
