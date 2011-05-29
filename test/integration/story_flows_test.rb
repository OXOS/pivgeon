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
        assert_notification("Re: [GeePivoMailin] Story 1") do
          post "/api", valid_params(@active_user.email,@owner.email)
        end
      end
      
      context "when pivotal server is crashed" do
        
        should "receive email informed that story hasn't been successfully created" do
          assert_notification("Re: [GeePivoMailin] Story 1") do
            Project.expects(:find_project_by_name).raises(ActiveResource::ServerError,'')
            post "/api", valid_params(@active_user.email,@owner.email)
          end
        end
        
      end
      
    end
    
    context "who creates story with invalid data" do
      
      context "like unexsisting project member as story owner but existing project name" do
        
        should "receive email informed that story hasn't been successfully created" do
          assert_notification("Re: [GeePivoMailin] Story 1") do
            post "/api", valid_params(@active_user.email,"any.people@example.com")
            assert_match /A person that you try to assign to the story is not a project member./, ActionMailer::Base.deliveries.last.body.encoded
            assert_no_match /Project that you try to create this story for does not exist./, ActionMailer::Base.deliveries.last.body.encoded
          end
        end
        
      end
      
      context "like unexisting project name but exsisting project member as story owner " do
        
        should "receive email informed that story hasn't been successfully created" do
          assert_notification("Re: [noexistingprojectname] Story name") do
            post "/api", valid_params(@active_user.email,"daniel@example.com","[noexistingprojectname] Story name")
            assert_no_match /A person that you try to assign to the story is not a project member./, ActionMailer::Base.deliveries.last.body.encoded
            assert_match /Project that you try to create this story for does not exist./, ActionMailer::Base.deliveries.last.body.encoded
          end
        end
        
      end
      
      context "like missing project name in email subject" do
        
        should "receive email informed that story hasn't been successfully created" do
          assert_notification("Re: subject without project name") do
            post "/api", valid_params(@active_user.email,"any.people@example.com","subject without project name")
            assert_match /Invalid data/, ActionMailer::Base.deliveries.last.body.encoded
          end
        end
        
      end
      
      context "like missing story name in email subject" do
        
        should "receive email informed that story hasn't been successfully created" do
          assert_notification("Re: [GeePivoMailin]") do
            post "/api", valid_params(@active_user.email,"any.people@example.com","[GeePivoMailin]")
            assert_match /Invalid data/, ActionMailer::Base.deliveries.last.body.encoded
          end
        end
        
      end
      
      context "like inproper formatted email subject" do
        
        should "receive email informed that story hasn't been successfully created" do
          assert_notification("Re: xxx [GeePivoMailin] Story 1") do
            post "/api", valid_params(@active_user.email,"any.people@example.com","xxx [GeePivoMailin] Story 1")
            assert_match /Invalid data/, ActionMailer::Base.deliveries.last.body.encoded
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
        assert_notification("Re: [GeePivoMailin] Story 1") do
          post "/api", valid_params(@inactive_user.email,@owner.email)
          assert_match /Unauthorized access/, ActionMailer::Base.deliveries.last.body.encoded
        end
      end
      
    end
    
    context "who creates story with invalid data" do
      
      should "receive email informed that story hasn't been successfully created" do
        assert_notification("Re: subject with missing project name") do
          post "/api", valid_params(@inactive_user.email,@owner.email,"subject with missing project name")
          assert_match /Unauthorized access/, ActionMailer::Base.deliveries.last.body.encoded
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
        assert_notification("Re: [GeePivoMailin] Story 1") do
          post "/api", valid_params("unexisting@example.com",@owner.email)
          assert_match /Unauthorized access/, ActionMailer::Base.deliveries.last.body.encoded
        end
      end
        
    end
    
    context "who creates story with invalid data" do
      
      should "receive email informed that story hasn't been successfully created" do
        assert_notification("Re: subject with missing project name") do
          post "/api", valid_params("unexisting@example.com",@owner.email,"subject with missing project name")
          assert_match /Unauthorized access/, ActionMailer::Base.deliveries.last.body.encoded
        end
      end
      
    end
    
  end
  
end