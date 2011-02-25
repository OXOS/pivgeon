require "test_helper.rb"

class StoryTest < ActiveSupport::TestCase
  
  fixtures(:all)
  
  context "A story" do
    
    setup do
      mock_requests()
      @incomming_message = incoming_params("wojciech@example.com","daniel@example.com","147449:Story 1")['message']
      @attrs = new_story_attrs("wojciech@example.com","daniel@example.com","12345678")      
    end
    
    context "when parse message" do
    
      context "that has inproper subject format" do
        
        should "raise exception" do
          incomming_params = incoming_params("wojciech@example.com","daniel@example.com",":Story 1")['message']
          message = Mail.new(incomming_params)
          assert_raises(ArgumentError) do
            Story.parse_message(message)
          end
        end
        
      end
  
      context "that is complete" do  
        
        should "return data hash" do
          message = Mail.new(@incomming_message)
          message.body = "description"
          params = {:story_type=>"chore",:name=>"Story 1", :description=>"description", :requested_by=>"wojciech@example.com", :owned_by=>"daniel@example.com", :project_id=>"147449"}
          assert_equal(params, Story.parse_message(message))
        end       
        
      end
      
    end    
    
    should "set story owner" do
      Story.expects(:token).returns("12345678")
      story = Story.new(:owned_by=>"daniel@example.com", :project_id=>"147449")      
      story.send("set_story_owner")
      assert_equal "daniel", story.attributes['owned_by']
    end
    
    should "find user by email" do
      user = users(:wojciech)
      assert_equal user.id, Story.new().find_user_by_email(user.email).id
    end
    
    should "get memberships for project" do
      story = Story.create(@attrs)
      memberships = story.get_memberships_for_project()      
      assert_equal ["wojciech@example.com", "daniel@example.com"], memberships.map{|m| m.person.email}
    end
    
    should "set token in headers" do
      Story.token = "12345678"
      assert_equal '12345678', Story.headers['X-TrackerToken']
      
      Story.token = ''
      assert Story.headers['X-TrackerToken'].blank?
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
                pivotal_story_response,
                201)
      mock.get("/services/v3/projects/147449/memberships.xml", 
                {"Accept"=>"application/xml", "X-TrackerToken"=>'12345678'}, 
                pivotal_memberships_response,
                201)     
      mock.post("/services/v3/projects//stories.xml", 
                {"Content-Type"=>"application/xml", "X-TrackerToken"=>'12345678'}, 
                nil,
                500)        
      mock.get("/services/v3/projects//memberships.xml", 
                {"Accept"=>"application/xml", "X-TrackerToken"=>'12345678'}, 
                pivotal_memberships_response_with_no_records,
                500)               
    end
  end
  
  def deb
    require "ruby-debug"
    debugger
  end
  
end
