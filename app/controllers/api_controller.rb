class ApiController < ApplicationController
  require 'net/http/post/multipart'
  
  skip_before_filter :verify_authenticity_token
  rescue_from Exception, :with => :handle_exceptions
  
  def create     

      @message = SendgridMessage.new(params)
      Rails.logger.info "\n@message = \n#{@message.inspect}\n\n"
      
      @user = User.find_by_email(@message.from)
      raise(SecurityError) if @user.blank?
  
      uri = URI.parse("http://book-order-pivgeon.herokuapp.com")
      
      response = Net::HTTP.start(uri.host, uri.port) do |http|
        
        params_ = {}
        params.each_pair do |k,v|
          v = v.read if v.is_a?(ActionDispatch::Http::UploadedFile)
          params_[k] = v
        end
      
        req = Net::HTTP::Post::Multipart.new("/stories/new",params_)
        response = http.request(req).body
        RAILS_DEFAULT_LOGGER.info "/n/n/n/n" + response.inspect + "/n/n/n/n"       
      end
      
      render(:text => "Ok", :status => 200)
  end
  
  protected         
   
  def handle_exceptions(e)

    begin
     headers["Content-type"] = "text/plain"
      case e
      when ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid, RecordNotSaved
        render_and_send_notification()
      when ActiveResource::UnauthorizedAccess, SecurityError
        render_and_send_notification("Unauthorized access")
      when ArgumentError
        render_and_send_notification("Invalid data")
      when ActiveResource::ServerError, ActiveResource::TimeoutError
        render_and_send_notification("Server error")
      else 
        Rails.logger.info("Raised Exception: #{e.message} | \n#{e.backtrace}")
        render_and_send_notification("Unknown error")
      end
    rescue => e
      Rails.logger.info("Raised Exception: #{e.message} | \n#{e.backtrace}")
      render(:text => "Error", :status => 200)
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
    Story.send_notification(@story,nil,:message_id => @message.message_id, :message_subject => @message.subject)
  end
  
  def send_notification_for_exception(error_message)
    Story.send_notification(@message,error_message,:message_id => @message.message_id, :message_subject => @message.subject)
  end
  
end
