class StoryMailer < ActionMailer::Base
  default :from => "pivgeon@pivgeon.com"
  layout "application"
  helper :application
  
  def created_notification(story,message,reference_message_id)
    @story = story
    set_reference_message_id(reference_message_id)
    mail(:to => story.user.email, :from => from, :reply_to => "pivgeon@pivgeon.com", :subject => "#{APP_NAME}: new story created")
  end
  
  def not_created_notification(story,message,reference_message_id)
    @email = ( story.is_a?(Story) ? story.user.email : story.from.first )
    @story = story
    @error_message = message
    set_reference_message_id(reference_message_id)
    mail(:to => @email, :from => from, :reply_to => "pivgeon@pivgeon.com", :subject => "#{APP_NAME}: error creating new story")
  end
  
  def from()
    %{"#{APP_NAME}" <pivgeon@pivgeon.com>}
  end
  
  def set_reference_message_id(message_id)
    headers({"In-Reply-To" => message_id, "References" => message_id}) if message_id
  end
  
end
