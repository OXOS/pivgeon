require 'test_helper'

class ApiControllerTest < ActionController::TestCase
  
  fixtures :all
  
  context "An existing user" do
                
    context "who sends email to somebody else and cc to cloudmailin" do
            
      setup do
        @params = incoming_params("wojciech@example.com","daniel@example.com")
      end
      
      should "create story" do
        user = users(:wojciech)
        Story.expects(:create).returns(mock('Story','new?'=>false))
        post :create, incoming_params(user.email,"daniel@example.com")
        assert_response :success
      end
      
    end
  end
  
  context "A not existing user" do
    
    context "who sends email to somebody else and cc to cloudmailin" do
    
        should "not create new story" do
          Story.expects(:create).raises(ActiveResource::ConnectionError,"")
          ActiveResource::ConnectionError.any_instance.stubs(:response).returns(mock("response",:code=>401))
          post :create, incoming_params("annonymous@example.com","daniel@example.com")
          assert_response 401
        end
        
    end
    
    context "who sends email directly to cloudmailin" do
      
      context "with valid data" do
      
        should "create inactive user" do
          User.expects(:create).returns(mock('User','new_record?'=>false))                
          post :create, incoming_params("annonymous@example.com",CLOUDMAILIN_EMAIL_ADDRESS,"12345678")
        end
        
        should "get email with activation link" do
          UserMailer.expects(:registration_confirmation).returns(mock('UserMailerObject','deliver'=>true)) 
          post :create, incoming_params("annonymous@example.com",CLOUDMAILIN_EMAIL_ADDRESS,"12345678")
        end
        
      end
    
    end
    
    
  end

end
