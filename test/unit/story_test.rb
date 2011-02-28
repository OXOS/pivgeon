require "test_helper.rb"

class StoryTest < ActiveSupport::TestCase
  
  fixtures(:all)
  
  context "A story" do
    
    setup do
      mock_requests()
      @incomming_message = valid_params("wojciech@example.com","daniel@example.com")['message']
      @attrs = new_story_attrs("daniel@example.com")      
    end
    
    should "valididate subject format" do
      assert !Story.valid_subject_format?("12345")
      assert !Story.valid_subject_format?("12345:")
      assert !Story.valid_subject_format?("]12345")
      assert !Story.valid_subject_format?("[]12345")
      assert !Story.valid_subject_format?("asdada[]")      
      assert !Story.valid_subject_format?("")
      assert Story.valid_subject_format?("[GeePivoMailin]asdadads")
      assert Story.valid_subject_format?("[GeePivoMailin] asdadads")
      assert Story.valid_subject_format?(" [GeePivoMailin]asdadads")
      assert Story.valid_subject_format?("[123]asdadads")
    end
    
    should "parse subject" do      
      assert_equal( {:name=>"some text",:project_id=>"GeePivoMailin"}.values.sort, Story.parse_subject("[GeePivoMailin]some text").values.sort )
      assert_equal( {:name=>"some text",:project_id=>"GeePivoMailin"}.values.sort, Story.parse_subject(" [GeePivoMailin]some text").values.sort )
      assert_equal( {:name=>" some text",:project_id=>"GeePivoMailin"}.values.sort, Story.parse_subject("[GeePivoMailin] some text").values.sort )
      assert_equal( {:name=>":some text",:project_id=>"GeePivoMailin"}.values.sort, Story.parse_subject("[GeePivoMailin]:some text").values.sort )
      assert_equal( {:name=>"some text",:project_id=>"GeePivoMailin"}.values.sort, Story.parse_subject("[GeePivoMailin]Re:some text").values.sort )
      assert_equal( {:name=>"some text",:project_id=>"GeePivoMailin"}.values.sort, Story.parse_subject("[GeePivoMailin]RE:some text").values.sort )
      assert_equal( {:name=>"some text",:project_id=>"GeePivoMailin"}.values.sort, Story.parse_subject("[GeePivoMailin]re:some text").values.sort )
      assert_equal( {:name=>"some text",:project_id=>"GeePivoMailin"}.values.sort, Story.parse_subject("[GeePivoMailin]FWD:some text").values.sort )
      assert_equal( {:name=>"some text",:project_id=>"GeePivoMailin"}.values.sort, Story.parse_subject("[GeePivoMailin]Fwd:some text").values.sort )
      assert_equal( {:name=>"some text",:project_id=>"GeePivoMailin"}.values.sort, Story.parse_subject("[GeePivoMailin]fwd:some text").values.sort )
      assert_equal( {:name=>"some text",:project_id=>"GeePivoMailin"}.values.sort, Story.parse_subject("[GeePivoMailin] fwd: some text").values.sort )
      assert_equal( {:name=>"[sdaadd] some text",:project_id=>"GeePivoMailin"}.values.sort, Story.parse_subject("[GeePivoMailin][sdaadd] some text").values.sort )
      assert_equal( {:name=>"[sdaadd]Fwd some text",:project_id=>"GeePivoMailin"}.values.sort, Story.parse_subject("[GeePivoMailin][sdaadd]Fwd some text").values.sort )
    end
       
    should "set token in headers" do
      Story.token = "12345678"
      assert_equal '12345678', Story.headers['X-TrackerToken']
      
      Story.token = ''
      assert Story.headers['X-TrackerToken'].blank?
    end
       
    should "be successfully saved" do
      Story.token = "12345678"
      assert_false(Story.create(@attrs).new?)
    end
    
    should "find owner" do
      flunk("implement me")
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
      mock.get("/services/v3/projects.xml", 
                {"Accept"=>"application/xml", "X-TrackerToken"=>'12345678'}, 
                pivotal_projects_response,
                200)                
              
    end
  end
  
  def deb
    require "ruby-debug"
    debugger
  end
  
end
