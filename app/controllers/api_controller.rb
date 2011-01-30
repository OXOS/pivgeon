class ApiController < ApplicationController
  skip_before_filter :verify_authenticity_token  

  def create
    message = Mail.new(params[:message])    
    begin      
      if message.to.first == CLOUDMAILIN_EMAIL_ADDRESS
        create_user(message)
      else
        create_story(message)
      end   
    rescue ActiveResource::ConnectionError => error
      render(:nothing => true, :status => error.response.code) and return
    end         
  end
  
  protected
  
  def create_user(message)
    attrs = User.parse_message(message)
    if User.create(attrs).new_record?                      
      render(:nothing => true, :status => 403)
    else
      render(:nothing => true)
    end      
  end
  
  def create_story(message)
    attrs = Story.parse_message(message)
    if Story.create(attrs).new?                      
      render(:nothing => true, :status => 403)
    else
      render(:nothing => true)
    end      
  end
  
end
