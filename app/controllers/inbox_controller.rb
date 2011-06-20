class InboxController < ApplicationController
  skip_before_filter :verify_authenticity_token  
    
  def create
    msg = "Processing incoming email: " + params.inspect
    Rails.logger.info msg
    render :text => msg
  end
  
end
