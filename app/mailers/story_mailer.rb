class StoryMailer < ActionMailer::Base
  default :from => "geepivomailin@example.com"
  layout "application"
  helper :application
  
  def story_created(story)
    mail(:to => story.user.email, :subject => "GeePivoMailin: new story created")
  end
  
  def story_not_created(story)
    mail(:to => story.user.email, :subject => "GeePivoMailin: error creating new story")
  end
  
end
