require File.expand_path(File.dirname(__FILE__))+ '/../test_helper'

class UserFlowsTest < ActionDispatch::IntegrationTest
  include ActionDispatch::Assertions::PivGeonAssertions
  fixtures :all

  context "A nonuser" do
    
    setup do
      mock_requests()
    end
    
    context "who tries to create new account with valid data" do
      
      should "receive email with confirmation link" do
        assert_difference("User.count") do
          assert_notification("PivGeon: new user confirmation") do
            post "/api", valid_params("a.man@example.com",CLOUDMAILIN_EMAIL_ADDRESS,"123123131")
            assert !assigns(:user).status
          end
        end
      end
      
    end
    
    context "who  tries to create new account with invalid data" do
      
      context "like invalid token" do
      
        should "receive email informed that new account hasn't been created" do
          assert_no_difference("User.count") do
            assert_notification("PivGeon: create new account error") do
              post "/api", valid_params("a.man@example.com",CLOUDMAILIN_EMAIL_ADDRESS,"999999999999")
            end
          end
        end
      
      end
      
      context "like empty subject" do
      
        should "receive email informed that new account hasn't been created" do
          assert_no_difference("User.count") do
            assert_notification("PivGeon: create new account error") do
              post "/api", valid_params("a.man@example.com",CLOUDMAILIN_EMAIL_ADDRESS,"")
            end
          end
        end
      
      end
      
    end
    
  end
  
  context "An inactive user" do
    
    setup do
      mock_requests()
      @user = users(:not_activated_user)
    end
    
    context "who tries to create new account with valid data" do
      should "receive email with confirmation link" do
        assert_no_difference("User.count") do
          assert_notification("PivGeon: new user confirmation") do
            post "/api", valid_params(@user.email,CLOUDMAILIN_EMAIL_ADDRESS,"111111111")          
            assert !assigns(:user).status
          end
        end
      end
    end
    
    context "who tries to create new account with valid data but different than original data" do
      should "receive email with confirmation link" do
        assert_no_difference("User.count") do
          assert_notification("PivGeon: new user confirmation") do
            post "/api", valid_params(@user.email,CLOUDMAILIN_EMAIL_ADDRESS,"12345678")
            assert !assigns(:user).status
            assert_equal "12345678", assigns(:user).token            
          end
        end
      end
    end
    
    context "who tries to create new account with invalid data" do
      should "receive email informed that new account hasn't been created" do
        assert_no_difference("User.count") do
          assert_notification("PivGeon: create new account error") do
            post "/api", valid_params(@user.email,CLOUDMAILIN_EMAIL_ADDRESS,"999999999")
            assert !assigns(:user).status
          end
        end
      end
    end
    
    context "who tries to activate his account" do
      should "see page with information that account has been activated" do        
        post "/users/confirm/#{@user.activation_code}"
        assert assigns(:user).status
        assert_select "#box div", /Your account has been activated/
      end
    end
    
  end
  
  context "An active user" do
    
    setup do
      mock_requests()
      @user = users(:wojciech)
    end
    
    context "who tries to create new account with valid data" do
      should "receive email informed that he can't create another account using this email address" do
        assert_no_difference("User.count") do
          assert_notification("PivGeon: create new account error") do
            post "/api", valid_params(@user.email,CLOUDMAILIN_EMAIL_ADDRESS,"123123131")
            assert_match /There already exists an user account registered for this email address/, ActionMailer::Base.deliveries.last.body.encoded
          end
        end
      end
    end
    
    context "who tries to create new account with invalid data" do
      should "receive email informed that he can't create another account using this email address" do
        assert_no_difference("User.count") do
          assert_notification("PivGeon: create new account error") do
            post "/api", valid_params(@user.email,CLOUDMAILIN_EMAIL_ADDRESS,"999999999999")
            assert_match /There already exists an user account registered for this email address/, ActionMailer::Base.deliveries.last.body.encoded
          end
        end
      end
    end
    
    context "who tries to activate his account" do
      should "see page 404" do        
        post "/users/confirm/#{@user.activation_code}"
        assert_response 404
      end
    end
    
  end
  
  
  
end
