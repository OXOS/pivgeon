require 'test_helper'

class StoriesControllerTest < ActionController::TestCase
  
  context "A controller" do
    setup do
      @params = incoming_params("wojciech@example.com","daniel@example.com")
    end
    
    
    context "when tries to create story" do
  
      context "when story is created" do       

        should "render :success" do
          Story.expects(:create).with(@params['message']).returns(mock('new?'=>false))
          post :create, @params
          assert_response :success
        end
        
      end

      context "when story is not created" do   
        
        context "and exception is raised" do
          
          should "render response code returned from pivotal" do
            Story.expects(:create).with(@params['message']).raises(ActiveResource::ConnectionError,"")
            ActiveResource::ConnectionError.any_instance.stubs(:response).returns(mock("response",:code=>401))
            post :create, @params
            assert_response 401
          end
          
        end

        context "and exception is not raised" do
          
          should "render status code 500" do
            Story.expects(:create).with(@params['message']).returns(mock('new?'=>true))          
            post :create, @params
            assert_response 403
          end
          
        end
        
      end
      
    end
    
    
    context "when tries to create new user" do
      
      should "send email with link for confirmation" do
        
      end
      
      context "and received user's confirmation" do
        
        should "create new user" do
          
        end
        
        should "send email with confirmation that new user has been created" do
          
        end
        
      end
      
    end
    
  end

end
