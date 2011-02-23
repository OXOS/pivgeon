class ApiController < ApplicationController
  skip_before_filter :verify_authenticity_token  

  def create
    message = Mail.new(params[:message])    
    if direct_sent_to_cloudmailin?(message)
      create_user(message)
    else
      handle_connection_error{ create_story(message) }
    end   
  end
  
  protected
  
  def create_user(message)
    attrs = User.parse_message(message)  
    user = User.create(attrs)
    if user.new_record?
      Rails.logger.info "@@@@@@@@@@@@@@@@@ errors #{user.errors.full_messages}"
      render(:nothing => true, :status => 403)
    else
      render(:nothing => true)
    end
  end
  
  def create_story(message)
    attrs = Story.parse_message(message)
    attrs[:description] = params[:plain]
    if Story.create(attrs).new?                      
      render(:nothing => true, :status => 403)
    else
      render(:nothing => true)
    end      
  end
  
  def handle_connection_error &block
    begin
      yield
    rescue ActiveResource::ConnectionError => error
      render(:nothing => true, :status => error.response.code) and return
    end
  end
  
  def direct_sent_to_cloudmailin? message
    return message.to.first == CLOUDMAILIN_EMAIL_ADDRESS
  end
  
end
