require 'test_helper'

class StoriesControllerTest < ActionController::TestCase
  
  context "A controller" do
    setup do
      @params = incoming_params("wojciech@example.com","daniel@example.com")
    end
  
    context "when story is created" do
      setup do 
        Story.expects(:create).returns(mock('new?'=>false))
      end
      
      should "render :success" do
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
        should "render status code 500" do
          Story.expects(:create).returns(mock('new?'=>true))          
          post :create, @params
          assert_response 403
        end
      end
    end
  end

end
