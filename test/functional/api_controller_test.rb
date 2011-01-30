require 'test_helper'

class ApiControllerTest < ActionController::TestCase
  
  context "A controller" do
    
    should "create story when copy of email is sent to cloudmailin" do
      Story.expects(:create).returns(mock('Story','new?'=>true))
      post :create, incoming_params("wojciech@example.com","daniel@example.com")
    end
        
    context "when tries to create story" do
      
      setup do
        @params = incoming_params("wojciech@example.com","daniel@example.com")
      end
  
      context "when story is created" do       

        should "render :success" do
          Story.expects(:create).returns(mock('new?'=>false))
          post :create, @params
          assert_response :success
        end
        
      end

      context "when story is not created" do   
        
        context "and exception is raised" do
          
          should "render response code returned from pivotal" do
            Story.expects(:create).raises(ActiveResource::ConnectionError,"")
            ActiveResource::ConnectionError.any_instance.stubs(:response).returns(mock("response",:code=>401))
            post :create, @params
            assert_response 401
          end
          
        end

        context "and exception is not raised" do
          
          should "render status code 403" do
            Story.expects(:create).returns(mock('new?'=>true))          
            post :create, @params
            assert_response 403
          end
          
        end
        
      end
      
    end
      
    should "create user when email is sent directly to cloudmailin" do
      User.expects(:create).returns(mock('User','new_record?'=>false))
      post :create, incoming_params("daniel@example.com",CLOUDMAILIN_EMAIL_ADDRESS)
    end
    
#    context "when tries to create new user" do
#      
#      setup do
#        @params = incoming_params("daniel@example.com",CLOUDMAILIN_EMAIL_ADDRESS)
#      end
#      
#      should "send email with link for confirmation" do
#        
#      end
#      
#      context "and received user's confirmation" do
#        
#        should "create new user" do
#          
#        end
#        
#        should "send email with confirmation that new user has been created" do
#          
#        end
#        
#      end
#      
#    end
    
  end

end
