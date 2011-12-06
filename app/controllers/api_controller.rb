class ApiController < ApplicationController  
  skip_before_filter :verify_authenticity_token      
      
  def create

      @message = SendgridMessage.new(params)
      @user    = User.active.find_by_email(@message.from)
      
      unless @user
        Notifier.unauthorized_access(@message, @message.message_id).deliver
      else
        uri   = URI.parse("http://book-order-pivgeon.herokuapp.com")        
        Net::HTTP.start(uri.host, uri.port) do |http|
          req      = Net::HTTP::Post::Multipart.new("/stories/new/#{@user.token}",params)
          response = http.request(req).body
        end
      end
      
      render(:text => "Ok", :status => 200)
  end
    
end
