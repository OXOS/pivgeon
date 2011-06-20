class ApplicationController < ActionController::Base
  protect_from_forgery
  
  protected
  
  def handle_exception(&block)
    headers["Content-type"] = "text/plain" 
    begin
      block.call      
    rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid, RecordNotSaved
      resnder_and_send_notification()
    end  
  end
      
  def render_and_send_notification
    send_notification_for_object
    render(:text => "Done", :status => 200)
  end   
  
  def send_notification_for_object()
    _class,_object,_mailer = get_class_and_object()

    if _object.errors.empty?
      _mailer.created_notification(_object, nil, :message_id => @message['Message-ID'], :message_subject => @message.subject).deliver
    else
      _mailer.not_created_notification(_object, nil, :message_id => @message['Message-ID'], :message_subject => @message.subject).deliver
    end
  end
  
  def get_class_and_object()
    direct_sent_to_cloudmailin?(@message) ? [User,@user,UserMailer] : [Story,@story,StoryMailer]
  end

  rescue_from(Exception) do |e|
    error_message = case(e)
    when ArgumentError
      "Invalid data"
    when ActiveResource::UnauthorizedAccess, SecurityError
      "Unauthorized access" 
    when ActiveResource::ServerError, ActiveResource::TimeoutError
      "Server error"
    else
      "Unknown error"
    end
  
    render(:text => error_message, :status => 200)
    
    begin
      _class,_object = get_class_and_object()
      _class.mailer_class.not_created_notification(@message,error_message,:message_id => @message['Message-ID'], :message_subject => @message.subject).deliver
    #rescue
    #  #TODO: notify us *somehow*, so that we know people are not receiving error notifications...
    end

  end

end
