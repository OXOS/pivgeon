class ApiController < ApplicationController  
  skip_before_filter :verify_authenticity_token      
      
  def create

    begin
      @message = SendgridMessage.new(params)
      @user    = User.active.find_by_email(@message.from)
      
      unless @user
        Notifier.unauthorized_access(@message).deliver
      else
        uri   = URI.parse("http://book-order-pivgeon.herokuapp.com")        
        Net::HTTP.start(uri.host, uri.port) do |http|
          req      = Net::HTTP::Post::Multipart.new("/stories/new/#{@user.token}",params)
          response = http.request(req).body
        end
      end
    rescue Exception => e
      Notifier.internal_error(@message).deliver
    end

    render(:text => "Ok", :status => 200)
  end

  rescue_from(Exception) do |e|
    Rails.logger.info("Raised Exception: #{e.message} | \n#{e.backtrace}")
    render(:text => "Ok", :status => 200)
  end
    
end
