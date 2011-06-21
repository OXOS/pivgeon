class ApiController < ApplicationController
  require 'ostruct'

  skip_before_filter :verify_authenticity_token

  before_filter :parse_message
  before_filter :find_user  
  before_filter :find_project_and_story_name
  
  def create      
    handle_exception do           
      if direct_sent_to_cloudmailin?(@message)
        create_user(@message)
      else
        create_story(@message)
      end
    end
  end
  
  
  protected
    
  def create_user(message)    
    attrs = User.parse_message(message)  
    @user = User.find_or_build(attrs)      
    @user.save!
    render_and_send_notification()
  end
  
  def create_story(message)    
    attrs = {:user_id=>@user.id,
             :owner_email=>@message.to.first,
             :project_name=>@project_name,
             :name=>@story_name,
             :description=>params["text"]}
    Story.token = @user.token
    @story = Story.new(attrs)
    @story.save!
    render_and_send_notification()    
  end
  
  def direct_sent_to_cloudmailin?(message)
    return message.to.first == CLOUDMAILIN_EMAIL_ADDRESS
  end
  
  def parse_message
    to = Story.detokenize(params["to"])
    from = Story.detokenize(params["from"])
    headers = {'Message-ID' => ""}
    @message = OpenStruct.new({ :to => [to], :from => [from], :body => params["text"], :subject => params["subject"], :headers => headers})
    Rails.logger.info("\nMessage params:\n#{@message.inspect}\n\n")
  end
  
  def find_project_and_story_name
    handle_exception do       
      unless direct_sent_to_cloudmailin?(@message)        
          @project_name,@story_name = Story.get_project_and_story_name(@message.subject,params[:to])
      end
    end
  end
  
  def find_user
    handle_exception do
      unless direct_sent_to_cloudmailin?(@message)
        @user = User.active.find_by_email(@message.from.first)
        raise(SecurityError) if @user.blank?
      end
    end
  end
  
end
