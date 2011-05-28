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
