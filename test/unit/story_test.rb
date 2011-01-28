require 'test_helper'

class StoryTest < ActiveSupport::TestCase
  
  fixtures(:all)
  
  context "it" do
    
    setup do
      @incomming_message = incoming_params("wojciech@example.com","daniel@example.com")['message']
      @attrs = new_story_attrs("wojciech@example.com","daniel@example.com","12345678")      
    end
    
    should "create new story and post to pivotaltracker" do
      mock_request
      assert_false(Story.create(@attrs).new?)
    end
    
    should "parse incoming message" do
      assert_equal({:story_type=>"chore",:name=>"Story 1", :requested_by=>"wojciech", :owned_by=>"daniel", :token=>"12345678"}, Story.parse_message(@incomming_message))
    end
    
    should "set token in headers" do
      Story.set_token("12345678")
      assert_equal '12345678', Story.headers['X-TrackerToken']
      
      Story.set_token('')
      assert Story.headers['X-TrackerToken'].blank?
    end
    
    should "get username related to email" do
      assert_equal users(:wojciech), Story.find_user("wojciech@example.com")
    end
                
  end
  
  protected
    
  def mock_request()
    ActiveResource::HttpMock.respond_to do |mock|
      mock.post("/services/v3/projects/147449/stories.xml", 
                {"Content-Type"=>"application/xml", "X-TrackerToken"=>'12345678'}, 
                pivotal_response)
    end
  end

end
