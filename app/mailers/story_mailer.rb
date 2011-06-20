class StoryMailer < ActionMailer::Base
  default :from => "pivgeon@pivgeon.com"
  layout "mailer"
  helper :application
  
  def created_notification(story,message,options={})
    @story = story
    reference_message_id,received_message_subject = parse_options(options)    
    set_reference_message_id(reference_message_id)
    mail(:to => story.user.email, :from => from, :reply_to => "pivgeon@pivgeon.com", :subject => "Re: #{received_message_subject}")
  end
  
  def not_created_notification(story,message,options={})    
    @email = ( story.is_a?(Story) ? story.user.email : story.from.first )
    @story = story
    @error_message = message
    reference_message_id,received_message_subject = parse_options(options)
    set_reference_message_id(reference_message_id)
    mail(:to => @email, :from => from, :reply_to => "pivgeon@pivgeon.com", :subject => "Re: #{received_message_subject}")
  end
  
  protected
  
  def from()
    %{"#{APP_NAME}" <#{APP_URL}>}
  end
  
  def set_reference_message_id(message_id)
    headers({"In-Reply-To" => message_id, "References" => message_id}) if message_id
  end
  
  def parse_options(options)
    [options[:message_id],options[:message_subject]]   
  end
  
end
