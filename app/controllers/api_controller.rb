class ApiController < ApplicationController
  skip_before_filter :verify_authenticity_token  

  
  def create
    logger("create")
    message = Mail.new(params[:message])    
    if direct_sent_to_cloudmailin?(message)
      create_user(message)
    else
      handle_exceptions{ create_story(message) }
    end   
  end
  
  
  protected
  
  def create_user(message)
    logger("create user")
    attrs = User.parse_message(message)      
    user = User.create(attrs)
    render_proper_status(user.new_record?)
  end
  
  def create_story(message)
    logger("create story")
    attrs = Story.parse_message(message)
    attrs[:description] = params[:plain]
    story = Story.create(attrs)
    logger("story errors: #{story.errors.full_messages}")
    render_proper_status(story.new?)     
  end
  
  def render_proper_status(new_record=true)
    if new_record      
      logger("render status 403")
      render(:text => "Invalid data", :status => 403)
    else
      logger("render status 200")
      render(:nothing => true)
    end 
  end
  
  def direct_sent_to_cloudmailin?(message)
    return message.to.first == CLOUDMAILIN_EMAIL_ADDRESS
  end
  
  def logger(str)
    Rails.logger.info("############### #{str}")
  end
  
end
