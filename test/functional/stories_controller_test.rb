require 'test_helper'

class StoriesControllerTest < ActionController::TestCase
  
  context "A incomming message" do
  
    context "creates new story" do
      
      setup do
        Story.stubs(:create_story).returns(true)
      end
      
      should "and handle proper response status" do
        Story.stubs(:create_story).returns(true)
        post :create, mail_params
        assert_response :success
      end
      
    end
    
    context "does not create new story" do
      
      setup do
        Story.stubs(:create_story).returns(false)
      end
      
      should "and handle proper response status" do
        post :create, mail_params
        assert_response :error
      end
      
    end
  
  end

end
