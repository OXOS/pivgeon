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
      assert_match /http:\/\/geepivomailindev.heroku.com\/users\/confirm\//, email.encoded
    end
  end
  
end
