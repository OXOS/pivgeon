class ApplicationController < ActionController::Base
  protect_from_forgery
  
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
    if error_message.blank?
      send_notification_for_object()
    else
      send_notification_for_exception(error_message)
    end
    render(:text => "Error", :status => 200)
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
