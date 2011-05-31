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
          post "/api", valid_params(@active_user.email,@owner.email,nil)
          assert_match /You have created new story/, ActionMailer::Base.deliveries.last.body.encoded
        end
      end
      
      context "when pivotal server is crashed" do
        
        should "receive email informed that story hasn't been successfully created" do
          assert_notification("Re: [GeePivoMailin] Story 1") do
            Project.expects(:find_project_by_name).raises(ActiveResource::ServerError,'')
            post "/api", valid_params(@active_user.email,@owner.email,nil)
            assert_match /Server error/, ActionMailer::Base.deliveries.last.body.encoded
          end
        end
        
      end
      
      context "with project name" do
        
        context "set in email address" do
        
          should "receive email informed that story has been successfully created" do
            assert_notification("Re: subject without project name") do
              post "/api", valid_params(@active_user.email,@owner.email,"geepivomailin@pivgeon.com","subject without project name")
              assert_match /You have created new story/, ActionMailer::Base.deliveries.last.body.encoded
            end
          end
          
        end
       
        context "set in subject" do

          should "receive email informed that story has been successfully created" do
            assert_notification("Re: [geepivomailin] subject without project name") do
              post "/api", valid_params(@active_user.email,@owner.email,"pivgeon@pivgeon.com","[geepivomailin] subject without project name")
              assert_match /You have created new story/, ActionMailer::Base.deliveries.last.body.encoded
            end
          end

        end
        
        context "with matching existing project name without spaces" do
          
          context "passed in email" do
            
            should "receive email informed that story has been successfully created" do
              assert_notification("Re: subject without project name") do
                post "/api", valid_params(@active_user.email,@owner.email,"thisisgeepivomailin@pivgeon.com","subject without project name")
                assert_match /You have created new story/, ActionMailer::Base.deliveries.last.body.encoded
              end
            end
            
          end
          
          context "passed in subject" do
            
            should "receive email informed that story has been successfully created" do
              assert_notification("Re: [thisisgeepivomailin] subject without project name") do
                post "/api", valid_params(@active_user.email,@owner.email,nil,"[thisisgeepivomailin] subject without project name")
                assert_match /You have created new story/, ActionMailer::Base.deliveries.last.body.encoded
              end
            end
            
          end

        end
        
        context "with email address that contains spaces" do
            
            should "receive email informed that story has been successfully created" do
              assert_notification("Re: [this is gee pivo mailin] subject without project name") do
                post "/api", valid_params(@active_user.email,@owner.email,nil,"[this is gee pivo mailin] subject without project name")
                assert_match /You have created new story/, ActionMailer::Base.deliveries.last.body.encoded
              end
            end
            
          end
        
      end
          
    end
    
    context "who creates story with invalid data" do
      
      context "like unexsisting project member as story owner but existing project name" do
        
        should "receive email informed that story hasn't been successfully created" do
          assert_notification("Re: [GeePivoMailin] Story 1") do
            post "/api", valid_params(@active_user.email,"any.people@example.com",nil)
            assert_match /A person that you try to assign to the story is not a project member./, ActionMailer::Base.deliveries.last.body.encoded
            assert_no_match /Project '' that you try to create this story for does not exist./, ActionMailer::Base.deliveries.last.body.encoded
          end
        end
        
      end
      
      context "like unexisting project name but exsisting project member as story owner " do
        
        should "receive email informed that story hasn't been successfully created" do
          assert_notification("Re: [noexistingprojectname] Story name") do
            post "/api", valid_params(@active_user.email,"daniel@example.com",nil,"[noexistingprojectname] Story name")
            assert_no_match /A person that you try to assign to the story is not a project member./, ActionMailer::Base.deliveries.last.body.encoded
            assert_match /Project 'noexistingprojectname' that you try to create this story for does not exist./, ActionMailer::Base.deliveries.last.body.encoded
          end
        end
        
      end
      
      context "like missing project name in email subject and missing project name in email" do
        
        should "receive email informed that story hasn't been successfully created" do
          assert_notification("Re: subject without project name") do
            post "/api", valid_params(@active_user.email,"daniel@example.com",nil,"subject without project name")
            assert_match /Project '' that you try to create this story for does not exist./, ActionMailer::Base.deliveries.last.body.encoded
          end
        end
        
      end
      
      context "like missing story name in email subject" do
        
        should "receive email informed that story hasn't been successfully created" do
          assert_notification("Re: [GeePivoMailin]") do
            post "/api", valid_params(@active_user.email,"daniel@example.com",nil,"[GeePivoMailin]")
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
          post "/api", valid_params(@inactive_user.email,@owner.email,nil)
          assert_match /Unauthorized access/, ActionMailer::Base.deliveries.last.body.encoded
        end
      end
      
    end
    
    context "who creates story with invalid data" do
      
      should "receive email informed that story hasn't been successfully created" do
        assert_notification("Re: subject with missing project name") do
          post "/api", valid_params(@inactive_user.email,@owner.email,nil,"subject with missing project name")
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
          post "/api", valid_params("unexisting@example.com",@owner.email,nil)
          assert_match /Unauthorized access/, ActionMailer::Base.deliveries.last.body.encoded
        end
      end
        
    end
    
    context "who creates story with invalid data" do
      
      should "receive email informed that story hasn't been successfully created" do
        assert_notification("Re: subject with missing project name") do
          post "/api", valid_params("unexisting@example.com",@owner.email,nil,"subject with missing project name")
          assert_match /Unauthorized access/, ActionMailer::Base.deliveries.last.body.encoded
        end
      end
      
    end
    
  end
  
end
