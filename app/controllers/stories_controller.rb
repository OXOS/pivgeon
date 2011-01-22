class StoriesController < ApplicationController
  
  skip_before_filter :verify_authenticity_token  

  def create
    begin      
      story = Story.create(params[:message])
      if story.new?                      
        render(:nothing => true, :status => 403)
      else
        render(:nothing => true)
      end      
    rescue ActiveResource::ConnectionError => error
      render(:nothing => true, :status => error.response.code)
    end        
  end
end
