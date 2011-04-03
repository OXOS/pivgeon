require File.expand_path(File.dirname(__FILE__))+ '/../test_helper'

class UserMailerTest < ActionMailer::TestCase
  
  fixtures :all

  context "Mailer" do
    should "send confirmation" do
      user = users(:wojciech)
      email =  UserMailer.registration_confirmation(user).deliver!
      assert !ActionMailer::Base.deliveries.empty?
      assert_equal "wojciech@example.com", email.to.first
      assert_equal "GeePivoMailin: new user confirmation", email.subject
      assert_match /#{ActionMailer::Base.default_url_options[:host]}\/users\/confirm\//, email.encoded
    end
    
    should "send notification when user account is not created" do
      user = users(:wojciech)
      user.errors.add(:token, "message 1")
      user.errors.add(:email, "message 2")
      
      assert !user.errors[:token].empty?
      assert !user.errors[:email].empty?
      
      email =  UserMailer.not_created_notification(user).deliver!
      assert !ActionMailer::Base.deliveries.empty?
      assert_equal "wojciech@example.com", email.to.first
      assert_equal "GeePivoMailin: create new account error", email.subject
      assert_match /You or somebody else tried to create new user account in GeePivoMailin application using this email: #{user.email}. Unfortunately the account couldn't be created due to following errors:/, email.encoded
      assert_match /message 1/, email.encoded
      assert_match /message 2/, email.encoded
    end
  end
  
end
