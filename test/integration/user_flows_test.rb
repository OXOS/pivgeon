require File.expand_path(File.dirname(__FILE__))+ '/../test_helper'

class UserFlowsTest < ActionDispatch::IntegrationTest
  include ActionDispatch::Assertions::PivGeonAssertions
  fixtures :all

  context "A man without user account " do
    
    setup do
      mock_requests()
    end
    
    context "tries to create new account with valid data" do
      
      should "receive email with confirmation link" do
        assert_difference("User.count") do
          assert_notification("GeePivoMailin: new user confirmation") do
            post "/api", valid_params("a.man@example.com",CLOUDMAILIN_EMAIL_ADDRESS,"123123131")
          end
        end
      end
      
    end
    
    context "tries to create new account with invalid data" do
      
      context "like invalid token" do
      
        should "receive email informed that new account hasn't been created" do
          assert_no_difference("User.count") do
            assert_notification("GeePivoMailin: create new account error") do
              post "/api", valid_params("a.man@example.com",CLOUDMAILIN_EMAIL_ADDRESS,"999999999999")
            end
          end
        end
      
      end
      
      context "like empty subject" do
      
        should "receive email informed that new account hasn't been created" do
          assert_no_difference("User.count") do
            assert_notification("GeePivoMailin: create new account error") do
              post "/api", valid_params("a.man@example.com",CLOUDMAILIN_EMAIL_ADDRESS,"")
            end
          end
        end
      
      end
      
    end
    
  end
  
  
end
