require 'test_helper'

class StoryTest < ActiveSupport::TestCase
  
  context "A model" do
    
    setup do
      set_users()
      stub_story_headers({'X-TrackerToken'=>'12345678'})
    end
    
#    context "should validate" do
#      
#      should "presence of story type" do
#        story = Story.new(story_attrs)
#        test_presence_of(story,"story_type")      
#      end
#      
#      should "presence of name" do
#        story = Story.new(story_attrs)
#        test_presence_of(story,"name")      
#      end
#      
#      should "presence of requested_by" do
#        story = Story.new(story_attrs)
#        test_presence_of(story,"requested_by")      
#      end
#      
#      should "presence of owned_by" do
#        story = Story.new(story_attrs)
#        test_presence_of(story,"owned_by")      
#      end
#      
#    end
    
    should "create new story and post to pivotaltracker" do
      mock_request
      assert Story.create(incoming_params['message'])
    end
    
    should "parse incoming message" do
      assert_equal story_attrs, Story.parse_incoming_message(incoming_params['message'])
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
