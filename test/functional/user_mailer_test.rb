require File.expand_path(File.dirname(__FILE__))+ '/../test_helper'

class UserMailerTest < ActionMailer::TestCase
  
  fixtures :all

  context "Mailer" do        
    
    should "send notification when user account is created" do
      user = users(:wojciech)
      email =  UserMailer.created_notification(user).deliver!
      assert !ActionMailer::Base.deliveries.empty?
      assert_equal "wojciech@example.com", email.to.first
      assert_equal "PivGeon: new user confirmation", email.subject
      assert_match /#{ActionMailer::Base.default_url_options[:host]}\/users\/confirm\//, email.encoded
    end
    
    context "when user is not created" do
    
      should "send notification which contains error messages" do
        user = users(:wojciech)
        user.errors.add(:token, "message 1")
        user.errors.add(:email, "message 2")

        assert !user.errors[:token].empty?
        assert !user.errors[:email].empty?

        email =  UserMailer.not_created_notification(user).deliver!
        assert !ActionMailer::Base.deliveries.empty?
        assert_equal "wojciech@example.com", email.to.first
        assert_equal "PivGeon: create new account error", email.subject
        assert_match /You or somebody else tried to create new user account in PivGeon application using this email: #{user.email}. Unfortunately the account couldn't be created due to following errors:/, email.encoded
        assert_match /message 1/, email.encoded
        assert_match /message 2/, email.encoded
      end
      
      should "send notification which contains custom error message" do        
        message =  Mail.new(valid_params("wojciech@example.com","daniel@example.com")['message'])
        email =  UserMailer.not_created_notification(message,"This is custom error message").deliver!
        assert !ActionMailer::Base.deliveries.empty?
        assert_equal "wojciech@example.com", email.to.first
        assert_equal "PivGeon: create new account error", email.subject
        assert_match /You or somebody else tried to create new user account in PivGeon application using this email: wojciech@example.com. Unfortunately the account couldn't be created due to following errors:/, email.encoded
        assert_match /This is custom error message/, email.encoded
      end
      
    end
    
  end
  
end
