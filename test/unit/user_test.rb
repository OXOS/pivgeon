require File.expand_path(File.dirname(__FILE__))+ '/../test_helper'

class UserTest < ActiveSupport::TestCase
  
  fixtures :all
  
  context "User" do
    
    setup do
      mock_requests()
    end
                   
    should "be activated" do            
      user = User.create(:email=>"somebody@example.com",:token=>"123123131")
      assert_false user.new_record?
      assert_false user.status
      
      user.activate!
      assert user.status
    end
    
    should "parse incoming message" do
      message = Mail.new(valid_params("wojciech@example.com","cloudmailin@example.com","12345678")['message'])
      assert_equal({:email=>"wojciech@example.com",:token=>"12345678"}, User.parse_message(message))
    end
    
    should "scope active users" do
      active_users = [users(:daniel).id,users(:wojciech).id]
      assert_equal active_users.sort, User.active.map(&:id).sort
    end
    
    should "scope inactive users" do
      inactive_users = [users(:not_activated_user).id]
      assert_equal inactive_users.sort, User.inactive.map(&:id).sort
    end
    
    should "find or build" do      
      user = User.find_or_build(:email=>"new_user@example.com",:token=>"123123131")
      assert user.new_record?
      assert_equal "new_user@example.com", user.email
      assert_equal "123123131", user.token
      
      inactive_user = users(:not_activated_user)
      user = User.find_or_build(:email=>inactive_user.email,:token=>"123123131")
      assert !user.new_record?
      assert_equal "inactive@example.com", user.email
      assert_equal "123123131", user.token
    end
    
    should "send notification" do      
      assert_difference("ActionMailer::Base.deliveries.count") do
        user = users(:wojciech)
        User.send_notification(user,nil,nil)
        assert_equal "PivGeon: new user confirmation", ActionMailer::Base.deliveries.last.subject
      end
      
      assert_difference("ActionMailer::Base.deliveries.count") do
        user = users(:wojciech)
        user.errors.add(:base,"test error")
        User.send_notification(user,nil,nil)
        assert_equal "PivGeon: create new account error", ActionMailer::Base.deliveries.last.subject
      end
    end
    
    context "when not created" do
      
      should "raise exception" do
        existing_user = users(:daniel)
        assert_raise(ActiveRecord::RecordInvalid) do
          user = User.find_or_build(:email=>existing_user.email,:token=>"12345678")
          user.save!
        end
      end
      
    end
    
    context "when created" do
      
      context "with invalid params" do
        
        should "validate presence of email" do
          user = User.create
          assert !user.errors[:email].empty?
        end
        
        should "validate uniqueness of email" do
          existing_user = users(:daniel)
          user = User.create(:email=>existing_user.email)
          assert user.errors[:email].include?("There already exists an user account registered for this email address")
        end
        
        should "validate presence of token" do
          user = User.create(:email=>"test@example.com")
          assert !user.errors[:token].empty?
        end
        
        should "validate if token is working" do          
          user = User.create(:email=>"test@example.com",:token=>"1")
          assert user.errors[:token].include?("The given token '1' is invalid")
        end
        
      end     
                  
      context "with valid params" do
        
        should "be successfully saved" do
          assert_difference("User.count") do
            User.create(:email=>"test@example.com", :token=>"12345678")
          end
        end
        
      end
      
      should "generate activation code" do
        user = User.create(:email=>"test@example.com",:token=>"123123131")
        assert !user.activation_code.blank?
      end
      
    end
    
    context "when updated" do
      should "not validate presence of activation number" do
        @user = users(:not_activated_user)
        @user.activation_code = nil
        assert @user.save
      end
      
      should "not validate uniqueness of email" do
        @user = users(:not_activated_user)        
        assert @user.save
      end
    end
            
  end

end
