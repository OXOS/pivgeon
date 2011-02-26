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
    
    should "valididate subject format" do
      assert !Story.valid_subject_format?("12345")
      assert !Story.valid_subject_format?("12345:")
      assert !Story.valid_subject_format?(":12345")
      assert !Story.valid_subject_format?("asdada:12345")
      assert !Story.valid_subject_format?("asdada:asdada")      
      assert !Story.valid_subject_format?("")
      assert !Story.valid_subject_format?("asdadads")
      assert Story.valid_subject_format?("12345:adasdad")
      assert Story.valid_subject_format?("12345:12345")
    end
    
    should "parse subject" do      
      assert_equal( {:name=>"Fwd: some text",:project_id=>"147449"}, Story.parse_subject("147449:Fwd: some text") )
      assert_equal( {:name=>" some text",:project_id=>"147449"}, Story.parse_subject("147449: some text") )
      assert_equal( {:name=>"RE:some text",:project_id=>"147449"}, Story.parse_subject("147449:RE:some text") )
      assert_equal( {:name=>":RE:some text",:project_id=>"147449"}, Story.parse_subject("147449::RE:some text") )
    end
    
    should "set story owner" do
      Story.expects(:token).returns("12345678")
      story = Story.new(:owned_by=>"daniel@example.com", :project_id=>"147449")      
      story.send("set_story_owner")
      assert_equal "daniel", story.owned_by
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
    
    context "when created" do
      
      context "by existing user" do
        
        setup do
          @user = users(:wojciech)          
        end
        
        context "for not existing member" do

          should "not be created" do
            attrs = new_story_attrs(@user.email,"annonymous@example.com","12345678")
            story = Story.create(attrs)
            assert(story.new?)
          end

        end

        context "for existing member" do
          
          setup do
            @member = users(:daniel)
            @attrs = new_story_attrs(@user.email,@member.email,"12345678")
          end

          context "with valid data" do

            should "be successfully saved" do               
              assert_false(Story.create(@attrs).new?)
            end

          end

          context "with invalid data" do
            
            context "like missed project_id" do
              
              should "not be saved" do 
                attrs = new_story_attrs(@user.email,@member.email,"12345678").merge(:project_id=>"")
                assert_raises(ActiveResource::ServerError) do
                  Story.create(attrs)
                end
              end
              
            end
            
            context "like wrong project_id" do
              
              should "not be saved" do 
                attrs = new_story_attrs(@user.email,@member.email,"12345678").merge(:project_id=>"404404404")
                assert_raises(ActiveResource::ResourceNotFound) do
                  Story.create(attrs)
                end
              end
              
            end
             
          end

        end              
        
        context "by not existing user" do
          
          should "not be created" do
            attrs = new_story_attrs("annonymous@example.com","daniel@example.com","12345678")
            assert_raises(SecurityError) do
              Story.create(attrs)
            end
          end
        end
        
      end
      
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
      mock.post("/services/v3/projects/404404404/stories.xml", 
                {"Content-Type"=>"application/xml", "X-TrackerToken"=>'12345678'}, 
                nil,
                404)    
       mock.get("/services/v3/projects/404404404/memberships.xml", 
                {"Accept"=>"application/xml", "X-TrackerToken"=>'12345678'}, 
                pivotal_memberships_response,
                201)     
      mock.get("/services/v3/projects//memberships.xml", 
                {"Accept"=>"application/xml", "X-TrackerToken"=>'12345678'}, 
                nil,
                500)               
              
    end
  end
  
  def deb
    require "ruby-debug"
    debugger
  end
  
end
