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
      SendgridMessage.expects(:new).returns(mock(:from => @user.email, :message_id => "123"))
      User.expects(:find_by_email).returns(nil)
      Notifier.expects(:unauthorized_access).returns(mock(:deliver => true))

      post :create
      assert_response :success
    end

  end
  
end  
