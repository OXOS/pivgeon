class StoryMailer < ActionMailer::Base
  default :from => "pivgeon@pivgeon.com"
  layout "application"
  helper :application
  
  def created_notification(story,message=nil)
    @story = story
    mail(:to => story.user.email, :subject => "#{APP_NAME}: new story created")
  end
  
  def not_created_notification(story,message=nil)
    @email = ( story.is_a?(Story) ? story.user.email : story.from.first )
    @story = story
    @error_message = message
    mail(:to => @email, :subject => "#{APP_NAME}: error creating new story")
  end
  
end
