class UsersController < ApplicationController
  require 'net/http/post/multipart'

  layout "application"    
  
  def new
              
      uri = URI.parse("http://book-order-pivgeon.herokuapp.com")
      
      File.open("#{RAILS_ROOT}/file.txt") do |jpg|
          
        params = { :cc => 'test@devel.pivgeon.com',
                   :html => '<br>\n',
                   :charsets => '{"to":"UTF-8","cc":"UTF-8","html":"ISO-8859-1","subject":"UTF-8","from":"UTF-8","text":"ISO-8859-1"}',
                   :dkim => 'none',
                   :from => 'Daniel Sokolowski <daniel@oxos.pl>',
                   :action => 'create',
                  'attachment-info' => '{"attachment1":{"filename":"file.tar","name":"file.tar","type":"application/x-tar"}}',
                   :text => '\n',
                   :subject => 'dora 6',
                   :to => 'Daniel Sokolowski <daniel@oxos.pl>',
                   :envelope => '{"to":["test@devel.pivgeon.com"],"from":"daniel@oxos.pl"}',
                   :attachment1 => UploadIO.new(jpg, "image/jpeg", "#{RAILS_ROOT}/file.txt"), 
                   :attachments => 1}
      
        response = Net::HTTP.start(uri.host, uri.port) do |http|
          req = Net::HTTP::Post::Multipart.new("/stories/new",params)
          response = http.request(req).body
          RAILS_DEFAULT_LOGGER.info "/n/n/n/n" + response.inspect + "/n/n/n/n"       
        end
        
      end
      
      render(:text => "Ok", :status => 200)
    
    #@user = User.new
  end 

  def create
    @user = User.new params[:user]
    if @user.save
      redirect_to user_path(@user)
    else
      render :action => :new
    end
  end
    
  def show
    @message = "Congratulations, your account has been created."
  end
  
end
