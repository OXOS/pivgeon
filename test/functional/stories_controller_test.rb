require 'test_helper'

class StoriesControllerTest < ActionController::TestCase
  
  context "A controller" do
  
    context "when story is created" do
      
      setup do 
        Story.expects(:create).with(incoming_params['message']).returns(mock('new?'=>false))
      end
      
      should "render :success" do
        post :create, incoming_params
        assert_response :success
      end
      
    end
    
    context "when story is not created" do
                              
      should "render :failed when story is not valid" do        
        Story.expects(:create).with(incoming_params['message']).returns(mock('new?'=>true))
        post :create, incoming_params
        assert_response :error
      end
      
      should "render :failed when an error is raised" do
        Story.expects(:create).with(incoming_params['message']).raises(ActiveResource::ConnectionError,"")
        post :create, incoming_params
        assert_response :error
      end
      
    end
  
  end

end
