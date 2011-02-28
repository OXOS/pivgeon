class ApplicationController < ActionController::Base
  protect_from_forgery
  
  protected
  
  rescue_from(ArgumentError) do |exception|
    render(:text => "Invalid data", :status => 403) and return
  end
  
  rescue_from(SecurityError) do |exception|
    render(:text => "Access denied", :status => 403) and return
  end
  
#  rescue_from(ActiveResource::ConnectionError) do |exception|
#    render(:text => exception.response.body, :status => exception.response.code) and return
#  end
#  
#  rescue_from(ActiveResource::ConnectionError) do |exception|
#    render(:text => exception.response.body, :status => exception.response.code) and return
#  end
  
end
