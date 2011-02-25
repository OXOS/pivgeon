class ApplicationController < ActionController::Base
  protect_from_forgery
  
  protected
  
  def handle_exceptions &block
    begin
      yield
    rescue ActiveResource::ConnectionError => error
      render(:text => error.response.body, :status => error.response.code) and return
    rescue ActiveResource::ServerError => error
      render(:text => error.response.body, :status => error.response.code) and return
    rescue ArgumentError => error
      render(:text => "Invalid data", :status => 403) and return
    rescue SecurityError => error
      render(:text => "Access denied", :status => 403) and return
    end
  end
  
end
