class StoryMailer < ActionMailer::Base
  default :from => "geepivomailin@example.com"
  layout "application"
  helper :application
  
  def created_notification(story,message=nil)
    @story = story
    mail(:to => story.user.email, :subject => "GeePivoMailin: new story created")
  end
  
  def not_created_notification(story,message=nil)
    @email = ( story.is_a?(Story) ? story.user.email : story.from.first )
    @story = story
    @error_message = message
    mail(:to => @email, :subject => "GeePivoMailin: error creating new story")
  end
  
end
