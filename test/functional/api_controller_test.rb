require File.expand_path(File.dirname(__FILE__))+ '/../test_helper'
require "ostruct"

class ApiControllerTest < ActionController::TestCase
  include ActionController::Assertions::PivGeonAssertions
  fixtures :all
  
  context "A controller" do  
            
    setup do   
      mock_requests
      @user = users(:wojciech)
      @owner = users(:daniel)            
    end
    
     
    should "create" do
      SendgridMessage.expects(:new).returns(mock(:from => @user.email))
      User.expects(:find_by_email).returns(@user)
      Net::HTTP.any_instance.expects(:request).returns(OpenStruct.new(:body=>"ok"))

      post :create
      assert_response :success
    end
    
    should "not create" do
      SendgridMessage.expects(:new).returns(mock(:from => @user.email))
      User.expects(:find_by_email).returns(nil)
      Notifier.expects(:unauthorized_access).returns(mock(:deliver => true))

      post :create
      assert_response :success
    end

    should "send email to the user when exception raised" do
      SendgridMessage.expects(:new).returns(mock(:from => @user.email))
      User.expects(:find_by_email).raises(Exception, 'message')
      Notifier.expects(:internal_error).returns(mock(:deliver => true))

      post :create
      assert_response :success
    end

    should "return status 200 even when mailer raises exception" do
      SendgridMessage.expects(:new).returns(mock(:from => @user.email))
      User.expects(:find_by_email).raises(Exception, 'message')
      Notifier.expects(:internal_error).raises(Exception, 'message')
      
      post :create
      assert_response :success
    end

  end
  
end  
