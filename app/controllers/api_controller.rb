class ApiController < ApplicationController
  require 'net/http/post/multipart'
  
  skip_before_filter :verify_authenticity_token
  
  #TODO: for this gem, fix the issue and publish in github
  Net::HTTP::Post::Multipart::Parts::FilePart.class_eval do
    def initialize(boundary, name, io)
      file_length = io.respond_to?(:length) ? io.length : File.size(io.path)
      @head = build_head(boundary, name, io.original_filename, io.content_type, file_length,
                         io.respond_to?(:opts) ? io.opts : {})
      @foot = "\r\n"
      @length = @head.length + file_length + @foot.length
      @io = CompositeReadIO.new(StringIO.new(@head), io, StringIO.new(@foot))
    end
  end
  
  def create     
      @message = SendgridMessage.new(params)
      @user = User.find_by_email(@message.from)
      
      render_and_send_notification("Unauthorized access") if @user.blank?
  
      uri = URI.parse("http://book-order-pivgeon.herokuapp.com")
      response = Net::HTTP.start(uri.host, uri.port) do |http|
        req = Net::HTTP::Post::Multipart.new("/stories/new",params)
        response = http.request(req).body
        RAILS_DEFAULT_LOGGER.info "/n/n/n/n" + response.inspect + "/n/n/n/n"       
      end
      
      render(:text => "Ok", :status => 200)
  end
  
  protected         
   
  def render_and_send_notification(error_message=nil)
    Notifier.unauthorized_access(@message, @message.message_id).deliver
    render(:text => "Error", :status => 200) and return
  end   
  
end
