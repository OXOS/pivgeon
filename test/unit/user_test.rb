require File.expand_path(File.dirname(__FILE__))+ '/../test_helper'

class UserTest < ActiveSupport::TestCase
  
  fixtures :all
  
  context "User" do
                   
    should "be activeted" do            
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
    
    should "find or create and send email" do
      assert_difference("User.count") do
        assert_difference('ActionMailer::Base.deliveries.count', 1) do
          User.find_or_create_and_send_email(:email=>"new_user@example.com",:token=>"134131231")
        end
      end
      
      inactive_user = users(:not_activated_user)
      assert_no_difference("User.count") do
        assert_difference('ActionMailer::Base.deliveries.count', 1) do
          User.find_or_create_and_send_email(:email=>inactive_user.email,:token=>"134131231")
        end
      end
    end
    
    context "when created" do
      
      should validate_presence_of(:token)    
      should validate_presence_of(:email)
      should validate_uniqueness_of(:email)
      
      context "with valid params" do
        
        should "be successfully saved" do
          assert_difference("User.count") do
            User.create(:email=>"test@example.com", :token=>"12345678")
          end
        end
        
      end
      
      should "generate activation code" do
        user = User.create(:email=>"test@example.com",:token=>"2345678")
        assert !user.activation_code.blank?
      end
      
      should "send confirmation email" do
        assert_difference "ActionMailer::Base.deliveries.count" do
          user = User.create(:email=>"test@example.com",:token=>"2345678")
        end
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
