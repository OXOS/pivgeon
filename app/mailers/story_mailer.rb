class StoryMailer < ActionMailer::Base
  default :from => "geepivomailin@example.com"
  layout "application"
  helper :application
  
  def created_for_creator(story,message=nil)
    @story = story
    mail(:to => story.user.email, :subject => "GeePivoMailin: new story created")
  end
  
  def created_for_owner(story,message=nil)
    @story = story
    mail(:to => story.user.email, :subject => "GeePivoMailin: new story assigned to you")
  end
  
  def not_created_for_creator(story,message=nil)
    @email = ( story.is_a?(Story) ? story.user.email : story.from.first )
    @story = story
    @error_message = message
    mail(:to => @email, :subject => "GeePivoMailin: error creating new story")
  end
  
end
