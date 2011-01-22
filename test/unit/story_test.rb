require 'test_helper'

class StoryTest < ActiveSupport::TestCase
  
  context "A model" do
    
    setup do
      set_users()
      @params = incoming_params("wojciech@example.com","daniel@example.com")
    end
    
    should "create new story and post to pivotaltracker" do
      mock_request
      assert Story.create(@params['message'])
    end
    
    should "parse incoming message" do
      assert_equal story_attrs, Story.parse_message_and_set_token(@params['message'])
    end
    
    should "set token in headers" do
      message = incoming_params("wojciech@example.com","daniel@example.com")['message']
      Story.parse_message_and_set_token(message)
      assert_equal '12345678', Story.headers['X-TrackerToken']
      
      message = incoming_params("faked_from@example.com","faked_to@example.com")['message']
      Story.parse_message_and_set_token(message)
      assert Story.headers['X-TrackerToken'].blank?
      
      message = incoming_params("daniel@example.com","wojciech@example.com")['message']
      Story.parse_message_and_set_token(message)
      assert_equal '87654321', Story.headers['X-TrackerToken']
    end
    
    should "get username related to email" do
      assert_equal "wojciech", Story.get_user_name("wojciech@example.com")
    end
                
  end
  
  protected
    
  def mock_request()
    ActiveResource::HttpMock.respond_to do |mock|
      mock.post "/services/v3/projects/147449/stories.xml", 
                {"Content-Type"=>"application/xml", "X-TrackerToken"=>'12345678'}, 
                pivotal_response
    end
  end

end
