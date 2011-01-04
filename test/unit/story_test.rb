require 'test_helper'

class StoryTest < ActiveSupport::TestCase
  
  context "A model" do
    
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
    
    should "create new story" do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.post "/services/v3/projects/147449/stories.xml", {"Content-Type"=>"application/xml", "X-TrackerToken"=>"eebe7dd0892e7156266362498942a8a2"}, pivotal_response
      end
      assert Story.create_story(mail_params)
    end
    
    should "parse incoming message" do
      assert_equal story_attrs, Story.parse_incoming_message(mail_params)
    end
    
  end

end
