require 'test_helper'

class StoryTest < ActiveSupport::TestCase
  
  fixtures(:all)
  
  context "A story" do
    
    setup do
      mock_requests()
      @incomming_message = incoming_params("wojciech@example.com","daniel@example.com","147449:Story 1")['message']
      @attrs = new_story_attrs("wojciech@example.com","daniel@example.com","12345678")      
    end
    
    should "parse incoming message" do
      message = Mail.new(@incomming_message)
      message.body = "description"
      params = {:story_type=>"chore",:name=>"Story 1", :description=>"description", :requested_by=>"wojciech@example.com", :owned_by=>"daniel@example.com", :project_id=>"147449"}
      assert_equal(params, Story.parse_message(message))
    end
    
    should "set story owner" do
      Story.expects(:token).returns("12345678")
      story = Story.new(:owned_by=>"daniel@example.com", :project_id=>"147449")      
      story.send("set_story_owner")
      assert_equal "daniel", story.attributes['owned_by']
    end
    
    should "get token by email" do      
      assert_equal "12345678", Story.new().send("find_user_token","wojciech@example.com")
    end
    
    should "set token in headers" do
      Story.token = "12345678"
      assert_equal '12345678', Story.headers['X-TrackerToken']
      
      Story.token = ''
      assert Story.headers['X-TrackerToken'].blank?
    end
    
    context "when created" do
      
      context "by message that doesn't contain project_id in subject" do
        
      end
      
      context "by message that doesn't contain story name in subject" do
        
      end
      
      context "by message that containt subject as string not separated by ':' " do
        
      end
      
    end
    
    context "when updated" do
      # not implemented yet
    end
    
    context "when deleted" do
      # not implemented yet
    end
    
    
    should "create new story and send send request to pivotal" do      
      assert_false(Story.create(@attrs).new?)
    end
                                       
  end
  
  protected
    
  def mock_requests()
    ActiveResource::HttpMock.respond_to do |mock|
      mock.post("/services/v3/projects/147449/stories.xml", 
                {"Content-Type"=>"application/xml", "X-TrackerToken"=>'12345678'}, 
                pivotal_story_response)
      mock.get("/services/v3/projects/147449/memberships.xml", 
                {"Accept"=>"application/xml", "X-TrackerToken"=>'12345678'}, 
                pivotal_memberships_response)              
    end
  end

  
  def deb
    require "ruby-debug"
    debugger
  end
  
end
