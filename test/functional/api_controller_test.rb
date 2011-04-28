require File.expand_path(File.dirname(__FILE__))+ '/../test_helper'

class ApiControllerTest < ActionController::TestCase
  include ActionController::Assertions::PivGeonAssertions
  fixtures :all
  
  context "A controller" do  
            
    setup do   
      mock_requests
      @user = users(:wojciech)
      @owner = users(:daniel)            
    end

    should "create story" do
      params = valid_params(@user.email,"daniel@example.com","[GeePivoMailin] Subject")
#      message = Mail.new(params['message'])
#      
#      Mail.expects(:new).retruns(message)
      
      post :create, params
      assert_response 200
    end

    should "not create story" do
      post :create, valid_params(@user.email,"daniel@example.com","Subject")
      assert_response 200, "Invalid data"
    end
      
    should "create user" do
      assert_notification("GeePivoMailin: new user confirmation") do
        post :create, valid_params("annonymous@example.com",CLOUDMAILIN_EMAIL_ADDRESS,"123123131")
      end
    end
    
    should "not create user" do
      assert_notification("GeePivoMailin: new user confirmation") do
        post :create, valid_params("annonymous@example.com",CLOUDMAILIN_EMAIL_ADDRESS,"123123131")
      end
    end
      
  end
  
end  
