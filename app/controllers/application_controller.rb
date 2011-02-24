class ApplicationController < ActionController::Base
  protect_from_forgery
  
  protected
  
  def handle_connection_error &block
    begin
      yield
    rescue ActiveResource::ConnectionError => error
      render(:nothing => true, :status => error.response.code) and return
    end
  end
  
end
