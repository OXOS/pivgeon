require File.expand_path(File.dirname(__FILE__))+ '/../test_helper'


class StoryTest < ActiveSupport::TestCase
  
  fixtures(:all)
  
  context "A story" do
    
    setup do
      mock_requests()
      @incomming_message = valid_params("wojciech@example.com","daniel@example.com")['message']
      @user = users(:wojciech)
      @project = Project.find_project_by_name("GeePivoMailin",@user.token)
      @attrs = new_story_attrs(@user.id,"daniel@example.com")      
    end
    
    context "validation" do
    
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
      
      should "validate owned_by" do
        story = Story.new(@attrs) 
        story.expects(:owner).returns(nil)
        assert_raise(RecordNotSaved) do
          story.save!
        end
        assert_equal "that you try to assign to the story is not a project member.", story.errors[:owned_by].first
      end
      
      should "validate project_id" do
        story = Story.new(@attrs) 
        story.expects(:project).at_least_once.returns(nil)
        assert_raise(RecordNotSaved) do
          story.save!
        end
        assert_equal "that you try to create this story for does not exist.", story.errors[:project].first
      end
      
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
    
    should "return owner" do
      project = Project.find_project_by_name("GeePivoMailin","12345678")      
      params = {:user_id=>@user.id,:owner_email=>"daniel@example.com",:project_name=>project.name,:name=>"test"}   
      story = Story.new(params)
      owner = story.owner()
      assert_equal "daniel", owner.person.name
      assert_equal "DS", owner.person.initials            
    end
    
    should "return project" do
      project = Project.find_project_by_name("GeePivoMailin","12345678")      
      params = {:user_id=>@user.id,:owner_email=>"daniel@example.com",:project_name=>project.name,:name=>"test"}   
      story = Story.new(params)
      project = story.project()
      assert_equal "GeePivoMailin", project.name      
    end
    
    should "set owned_by when saving" do
      story = Story.new(@attrs)
      story.save
      assert_equal "daniel", story.owned_by
    end
    
    should "set prefix option :project_id when saving" do
      story = Story.new(@attrs)
      story.save
      assert_equal "147449", story.prefix_options[:project_id].to_s
    end
    
    should "return proper url to story in pivotal tracker" do
      story = Story.new(@attrs)
      story.save
      assert_equal "https://www.pivotaltracker.com/story/show/100001", story.url
    end
    
    should "send notification" do      
      story = Story.create(@attrs)
      
      assert_difference("ActionMailer::Base.deliveries.count") do        
        Story.send_notification(story,nil)
        assert_equal "PivGeon: new story created", ActionMailer::Base.deliveries.last.subject
      end
      
      assert_difference("ActionMailer::Base.deliveries.count") do
        story.errors.add(:base,"test error")
        Story.send_notification(story,nil)
        assert_equal "PivGeon: error creating new story", ActionMailer::Base.deliveries.last.subject
      end
    end

  end
  
  protected
  
  def deb
    require "ruby-debug"
    debugger
  end
  
end
