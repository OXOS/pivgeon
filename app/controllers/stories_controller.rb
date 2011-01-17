class StoriesController < ApplicationController
  
  skip_before_filter :verify_authenticity_token  

  def create
    begin      
      story = Story.create(params[:message])
      if story.new? 
        render :text => 'failed', :status => 500
      else
        render :text => 'success', :status => 200
      end
      
    rescue ActiveResource::ConnectionError => error
      render :text => 'failed', :status => error.response.code

    end
  end

end
