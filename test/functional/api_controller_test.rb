require File.expand_path(File.dirname(__FILE__))+ '/../test_helper'

class ApiControllerTest < ActionController::TestCase
  
  fixtures :all
  
  context "An active user" do  
    
    setup do
      mock_requests()
    end
                
    context "who sends email to somebody else and cc to cloudmailin" do
            
      setup do        
        @user = users(:wojciech)
        @owner = users(:daniel)        
      end
      
      should "create story" do
        assert_notification("GeePivoMailin: new story created") do  
          post :create, valid_params(@user.email,"daniel@example.com","[GeePivoMailin] Subject")
        end
      end
      
      context "with invalid subject format" do
        should "not create story" do
          assert_difference("ActionMailer::Base.deliveries.count") do
            post :create, valid_params(@user.email,"daniel@example.com","Subject")
            assert_response 200, "Invalid data"
          end
        end
      end
      
      context "when email recipient is not project member" do
        should "not create story" do  
          Project.expects(:find_project_by_name).returns(nil)
          post :create, valid_params(@user.email,"annonymous@example.com","[GeePivoMailin] Subject")
          assert_response 200, "Invalid data"
        end
      end
      
      context "when pivotal tracker respond client error" do
        should "not create story" do          
          [ActiveResource::ForbiddenAccess,ActiveResource::UnauthorizedAccess,ActiveResource::BadRequest,ActiveResource::ResourceNotFound].each do |e|
            Project.stubs(:find_project_by_name).raises(e.new('',''))
            post :create, valid_params(@user.email,"annonymous@example.com","[GeePivoMailin] Subject")
            assert_response 200
          end
        end
      end
      
      context "when pivotal tracker respond connection error" do
        should "not create story" do          
          [ActiveResource::TimeoutError,ActiveResource::ServerError].each do |e|
            Project.stubs(:find_project_by_name).raises(e.new(''))
            post :create, valid_params(@user.email,"annonymous@example.com","[GeePivoMailin] Subject")
            assert_response 200
          end
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
        post :create, valid_params(@user.email,"daniel@example.com","[GeePivoMailin] subject")
        assert_response 200
      end
                  
    end
    
    context "who sends email directly to cloudmailin" do
      
      setup do
        @incomming_params = valid_params(@user.email,CLOUDMAILIN_EMAIL_ADDRESS,"12345678")
      end
      
      should "not create new user" do
        assert_notification("GeePivoMailin: new user confirmation") do
          assert_no_difference("User.count") do
            post :create, @incomming_params
          end
        end
      end
    
    end
    
  end
  
  context "A not existing user" do
    
    setup do
      mock_requests()
    end
    
    context "who sends email to somebody else and cc to cloudmailin" do
      should "not create new story" do
        assert_notification("GeePivoMailin: error creating new story") do  
          post :create, valid_params("annonymous@example.com","daniel@example.com","[GeePivoMailin] subject")
        end
      end
    end
    
    context "who sends email directly to cloudmailin" do
      context "with valid data" do
        should "create inactive user" do
          assert_notification("GeePivoMailin: new user confirmation") do
            post :create, valid_params("annonymous@example.com",CLOUDMAILIN_EMAIL_ADDRESS,"123123131")
          end
        end
      end
    end
    
  end
  
end
