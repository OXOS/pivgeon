class StoriesController < ApplicationController
  
  skip_before_filter :verify_authenticity_token

  def create
    if Story.create_story(params[:message])
      render :text => 'success', :status => 200
    else
      render :text => 'failed', :status => 500
    end
  end

end
