require File.expand_path(File.dirname(__FILE__))+ '/../test_helper'

class ProjectTest < ActiveSupport::TestCase
  
  fixtures :all
  
  context "Project" do
    
    setup do
      mock_request()
    end
    
    should "set token in headers" do
      Project.token = "12345678"
      assert_equal '12345678', Project.headers['X-TrackerToken']
      
      Project.token = ''
      assert Project.headers['X-TrackerToken'].blank?
    end
    
    should "standarize_name" do      
      assert_equal "thisisastoryname", Project.standarize_name("This is a STORYname")
      assert_equal "anewstory", Project.standarize_name("aNewStory")
      assert_equal "thisisnewname", Project.standarize_name("(thisIsNew)name")
      assert_equal "thisisnew-name007", Project.standarize_name("thisIsNew-name007")
      assert_equal "thisisnewname", Project.standarize_name("[thisIsNew]name")
      assert_equal "this/isnew/story", Project.standarize_name("this/isnew/story")
      assert_equal "{thisisnew}name|old", Project.standarize_name("{thisIsNew}name|old")
    end
    
    should "compare_names" do
      assert Project.compare_names("anewstory","A New story")
      assert Project.compare_names("this is a new story","This Is A New Story")
      assert Project.compare_names("this is a new story","ThisIsANewStory")
      assert Project.compare_names("First story","first story")
      assert Project.compare_names("projectnameno007|15|11","Project Name No 007|15|11")
      assert Project.compare_names("firstprojectformatti!(beta)","First project for Matti! (beta)")
      assert Project.compare_names("projecttestbeta","Project test [beta]")
      assert Project.compare_names("projecttestaaa/bbb","Project test AAA/BBB")
      assert Project.compare_names("projecttommy&jerry100","Project Tommy&Jerry #100")
    end
    
    should "case insensitive find project by name" do
      project = Project.find_project_by_name("GeePivoMailin","12345678")
      assert_equal "GeePivoMailin", project.name
      assert_equal "147449", project.id
      
      project = Project.find_project_by_name("geepivomailin","12345678")
      assert_equal "GeePivoMailin", project.name
      assert_equal "147449", project.id
      
      project = Project.find_project_by_name("geePivomailin","12345678")
      assert_equal "GeePivoMailin", project.name
      assert_equal "147449", project.id
      
      project = Project.find_project_by_name("geepivomailin2","12345678")
      assert_equal "GeePivoMailin2", project.name
      assert_equal "147450", project.id
    end
    
    should "find project by name without white spaces" do
      project = Project.find_project_by_name("thisisgeepivomailin","12345678")
      assert_equal "This Is Gee Pivo Mailin", project.name
      
      project = Project.find_project_by_name("this is gee pivo mailin","12345678")
      assert_equal "This Is Gee Pivo Mailin", project.name
    end
    
  end
  
  protected
  
  def mock_request
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get("/services/v3/projects.xml", 
            {"Accept"=>"application/xml", "X-TrackerToken"=>'12345678'}, 
            pivotal_projects_response,
            200)
    end
  end
  
end
