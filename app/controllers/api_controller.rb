class ApiController < ApplicationController
  require 'ostruct'

  skip_before_filter :verify_authenticity_token

  before_filter :parse_message
  before_filter :find_user
  before_filter :find_project_and_story_name

  def create
    handle_exception do
      if direct_sent_to_cloudmailin?(@message)
        create_user(@message)
      else
        create_story(@message)
      end
    end
  end


  protected

  def create_user(message)
    attrs = User.parse_message(message)
    @user = User.find_or_build(attrs)
    @user.save!
    render_and_send_notification()
  end

  def create_story(message)
    attrs = {:user_id=>@user.id,
             :owner_email=>@message.to.first,
             :project_name=>@project_name,
             :name=>@story_name,
             :description=>params["text"]}
    Story.token = @user.token
    @story = Story.new(attrs)
    @story.save!
    render_and_send_notification()
  end

  def direct_sent_to_cloudmailin?(message)
    return message.to.first == CLOUDMAILIN_EMAIL_ADDRESS
  end

  def parse_message
    to = Story.detokenize(params["to"])
    from = Story.detokenize(params["from"])
    headers = {'Message-ID' => ""}
    @message = OpenStruct.new({ :to => [to], :from => [from], :body => params["text"], :subject => params["subject"], :headers => headers})
    Rails.logger.info("\nMessage params:\n#{@message.inspect}\n\n")
  end

  def find_project_and_story_name
    handle_exception do
      unless direct_sent_to_cloudmailin?(@message)
          @project_name,@story_name = Story.get_project_and_story_name(@message.subject,params[:cc])
      end
    end
  end

  def find_user
    handle_exception do
      unless direct_sent_to_cloudmailin?(@message)
        @user = User.active.find_by_email(@message.from.first)
        raise(SecurityError) if @user.blank?
      end
    end
  end

  protected

  def handle_exception(&block)
    headers["Content-type"] = "text/plain"
    begin
      block.call
    rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid, RecordNotSaved
      resnder_and_send_notification()
    end
  end

  def render_and_send_notification
    send_notification_for_object
    render(:text => "Done", :status => 200)
  end

  def send_notification_for_object()
    _class,_object,_mailer = get_class_and_object()

    if _object.errors.empty?
      _mailer.created_notification(_object, nil, :message_id => @message['Message-ID'], :message_subject => @message.subject).deliver
    else
      _mailer.not_created_notification(_object, nil, :message_id => @message['Message-ID'], :message_subject => @message.subject).deliver
    end
  end

  def get_class_and_object()
    direct_sent_to_cloudmailin?(@message) ? [User,@user,UserMailer] : [Story,@story,StoryMailer]
  end

  rescue_from(Exception) do |e|
    error_message = case(e)
    when ArgumentError
      "Invalid data"
    when ActiveResource::UnauthorizedAccess, SecurityError
      "Unauthorized access"
    when ActiveResource::ServerError, ActiveResource::TimeoutError
      "Server error"
    else
      "Unknown error"
    end

    render(:text => error_message, :status => 200)

    begin
      _class,_object = get_class_and_object()
      _class.mailer_class.not_created_notification(@message,error_message,:message_id => @message['Message-ID'], :message_subject => @message.subject).deliver
    #rescue
    #  #TODO: notify us *somehow*, so that we know people are not receiving error notifications...
    end

  end

end
