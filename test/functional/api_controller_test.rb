require 'test_helper'

class ApiControllerTest < ActionController::TestCase
  
  fixtures :all
  
  context "An active user" do
                
    context "who sends email to somebody else and cc to cloudmailin" do
            
      setup do        
        @user = users(:wojciech)
      end
      
      should "create story" do        
        Story.expects(:create).returns(mock('Story','new?'=>false))
        post :create, incoming_params(@user.email,"daniel@example.com","12345:Subject")
        assert_response :success
      end
      
      context "with invalid subject format" do
        should "get error raised" do          
          post :create, incoming_params(@user.email,"daniel@example.com",":Subject")
          assert_response 403, "Invalid data"
        end
      end
      
      context "when email recipient is not project member" do
        should "get error raised" do     
          Membership.expects(:find).raises(ActiveResource::ConnectionError)
          post :create, incoming_params(@user.email,"annonymous@example.com","1234:Subject")
          assert_response 403, "Invalid data"
        end
      end
      
    end
  end
  
  context "An inactive user" do
    
    setup do
      @user = users(:not_activated_user)
    end
    
    context "who sends email to somebody else and cc to cloudmailin" do
      
      should "not create new story" do
        post :create, incoming_params(@user.email,"daniel@example.com","12345:subject")
        assert_response 403
      end
                  
    end
    
    context "who sends email directly to cloudmailin" do
      
      setup do
        @incomming_params = incoming_params(@user.email,CLOUDMAILIN_EMAIL_ADDRESS,"12345678")
      end
      
      should "not create new user" do
        assert_no_difference("User.count") do
          post :create, @incomming_params
        end
      end

      should "get email with activation link" do
        UserMailer.expects(:registration_confirmation).returns(mock('UserMailerObject','deliver'=>true)) 
        post :create, @incomming_params
      end
    
    end
    
  end
  
  context "A not existing user" do
    
    context "who sends email to somebody else and cc to cloudmailin" do
    
      should "not create new story" do
        post :create, incoming_params("annonymous@example.com","daniel@example.com","12345:subject")
        assert_response 403
      end
        
    end
    
    context "who sends email directly to cloudmailin" do
      
      context "with valid data" do
      
        should "create inactive user" do
          User.expects(:find_or_create_and_send_email).returns(mock('User','new_record?'=>false))                
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
