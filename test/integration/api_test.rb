require File.expand_path(File.dirname(__FILE__))+ '/../test_helper'

class ApiTest < ActionDispatch::IntegrationTest
  include ActionDispatch::Assertions::PivGeonAssertions
  fixtures :all

  context "Existing and active user" do
    
    setup do
      mock_requests()
      @active_user = users(:wojciech)
      @owner = users(:daniel)
    end
      
    should "should be able to create new story" do
      post "/api", valid_params(@active_user.email,@owner.email)
      assert_response :success
    end
      
  end
  
  context "Unexisting user" do
    
    setup do
      mock_requests()
      @owner = users(:daniel)
    end
  
    should "receive email informed that access is denied" do
      assert_notification("Re: Story 1") do
        post "/api", valid_params("unexisting@example.com",@owner.email)
        assert_match /Unauthorized access/, ActionMailer::Base.deliveries.last.body.encoded
      end
    end
    
  end
  
end
