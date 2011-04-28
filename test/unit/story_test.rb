require File.expand_path(File.dirname(__FILE__))+ '/../test_helper'


class StoryTest < ActiveSupport::TestCase
  
  fixtures(:all)
  
  context "A story" do
    
    setup do
      mock_requests()
      @incomming_message = valid_params("wojciech@example.com","daniel@example.com")['message']
      @user = users(:wojciech)
      @attrs = new_story_attrs(@user.id,"daniel@example.com")      
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
      assert_equal( {:name=>"some text",:project_id=>"GeePivoMailin"}.values.sort, Story.parse_subject("[GeePivoMailin] PD: some text").values.sort )
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
      project = Project.find_project_by_name("GeePivoMailin","12345678")
      
      owner = Story.find_owner("daniel@example.com",project)
      assert_equal "daniel", owner.person.name
      assert_equal "DS", owner.person.initials
      
      owner = Story.find_owner("annonymous@example.com",project)
      assert_equal nil, owner
    end
    
    should "set owned_by" do
      story = Story.new
      story.owned_by = "daniel"
      assert_equal "daniel", story.owned_by
    end
    
    should "send notification" do      
      story = Story.create(@attrs)
      
      assert_difference("ActionMailer::Base.deliveries.count",2) do        
        Story.send_notification(story,nil)
        assert ActionMailer::Base.deliveries.map(&:subject).include?("GeePivoMailin: new story created")
        assert ActionMailer::Base.deliveries.map(&:subject).include?("GeePivoMailin: new story assigned to you")
      end
      
      assert_difference("ActionMailer::Base.deliveries.count") do
        story.errors.add(:base,"test error")
        Story.send_notification(story,nil)
        assert_equal "GeePivoMailin: error creating new story", ActionMailer::Base.deliveries.last.subject
      end
    end

  end
  
  protected
  
  def deb
    require "ruby-debug"
    debugger
  end
  
end
