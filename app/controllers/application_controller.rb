class ApplicationController < ActionController::Base
  protect_from_forgery
  
  protected
  
  def handle_exception(&block)
    headers["Content-type"] = "text/plain" 
    begin
      block.call
    rescue ActiveResource::UnauthorizedAccess, SecurityError
      Rails.logger.info("############### UnauthorizedAccess")
      render(:text => "Unauthorized Access", :status => 403) and return                      
      
    rescue ArgumentError
      Rails.logger.info("############### raised ArgumentError")
      render(:text => "Invalid data", :status => 403) and return
      
    rescue ActiveResource::ServerError, ActiveResource::TimeoutError
      Rails.logger.info("############### ActiveResource::ClientError")
      render(:text=>"Server Error", :status => 500) and return  
      
    rescue
      Rails.logger.info("############### Exception")
      render(:text=>"Error", :status => 403) and return
    end
  end
  
#  
#  rescue_from(ArgumentError) do |exception|
#    Rails.logger.info("############### raised ArgumentError")
#    render(:text => "Invalid data", :status => 403) and return
#  end
#  
#  rescue_from(SecurityError) do |exception|
#    Rails.logger.info("############### SecurityError")
#    render(:text => "Access denied", :status => 403) and return
#  end
#  
#  rescue_from(ActiveResource) do |exception|
#    require "ruby-debug"
#    debugger
#    Rails.logger.info("############### ActiveResource::ServerError")
#    render(:text => "Access denied", :status => 403) and return
#  end      
    
end
