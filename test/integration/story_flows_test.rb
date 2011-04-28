require File.expand_path(File.dirname(__FILE__))+ '/../test_helper'

class StoryFlowsTest < ActionDispatch::IntegrationTest
  include ActionDispatch::Assertions::PivGeonAssertions
  fixtures :all

  context "Existing and active user" do
    
    setup do
      mock_requests()
      @active_user = users(:wojciech)
      @owner = users(:daniel)
    end
    
    context "who creates story with valid data" do
      
      should "receive email informed that story has been successfully created" do
        assert_notification("GeePivoMailin: new story created") do
          post "/api", valid_params(@active_user.email,@owner.email)
#          debugger
#          puts 'asd'
        end
      end
      
      context "when pivotal server is crashed" do
        
        should "receive email informed that story hasn't been successfully created" do
          assert_notification("GeePivoMailin: error creating new story") do
            Project.expects(:find_project_by_name).raises(ActiveResource::ServerError,'')
            post "/api", valid_params(@active_user.email,@owner.email)
          end
        end
        
      end
      
    end
    
    context "who creates story with invalid data" do
      
      context "like unexsisting project member as story owner" do
        
        should "receive email informed that story hasn't been successfully created" do
          assert_notification("GeePivoMailin: error creating new story") do
            post "/api", valid_params(@active_user.email,"any.people@example.com")
          end
        end
        
      end
      
      context "like missing project name in email subject" do
        
        should "receive email informed that story hasn't been successfully created" do
          assert_notification("GeePivoMailin: error creating new story") do
            post "/api", valid_params(@active_user.email,"any.people@example.com","subject without project name")
          end
        end
        
      end
      
      context "like missing story name in email subject" do
        
        should "receive email informed that story hasn't been successfully created" do
          assert_notification("GeePivoMailin: error creating new story") do
            post "/api", valid_params(@active_user.email,"any.people@example.com","[GeePivoMailin]")
          end
        end
        
      end
      
      context "like inproper formatted email subject" do
        
        should "receive email informed that story hasn't been successfully created" do
          assert_notification("GeePivoMailin: error creating new story") do
            post "/api", valid_params(@active_user.email,"any.people@example.com","xxx [GeePivoMailin] Story 1")
          end
        end
        
      end
      
    end
    
  end
  
  context "Existing but inactive user" do
    
    setup do
      mock_requests()
      @inactive_user = users(:not_activated_user)
      @owner = users(:daniel)
    end
    
    context "who creates story with valid data" do
      
      should "receive email informed that story hasn't been successfully created" do
        assert_notification("GeePivoMailin: error creating new story") do
          post "/api", valid_params(@inactive_user.email,@owner.email)
          assert_match /Unauthorized access /, ActionMailer::Base.deliveries.last.body.encoded
        end
      end
      
    end
    
    context "who creates story with invalid data" do
      
      should "receive email informed that story hasn't been successfully created" do
        assert_notification("GeePivoMailin: error creating new story") do
          post "/api", valid_params(@inactive_user.email,@owner.email,"subject with missing project name")
          assert_match /Unauthorized access /, ActionMailer::Base.deliveries.last.body.encoded
        end
      end
      
    end
    
  end
  
  context "Unexisting user" do
    
    setup do
      mock_requests()
      @owner = users(:daniel)
    end
    
    context "who creates story with valid data" do
      
      should "receive email informed that story hasn't been successfully created" do
        assert_notification("GeePivoMailin: error creating new story") do
          post "/api", valid_params("unexisting@example.com",@owner.email)
          assert_match /Unauthorized access /, ActionMailer::Base.deliveries.last.body.encoded
        end
      end
        
    end
    
    context "who creates story with invalid data" do
      
      should "receive email informed that story hasn't been successfully created" do
        assert_notification("GeePivoMailin: error creating new story") do
          post "/api", valid_params("unexisting@example.com",@owner.email,"subject with missing project name")
          assert_match /Unauthorized access /, ActionMailer::Base.deliveries.last.body.encoded
        end
      end
      
    end
    
  end
  
end
