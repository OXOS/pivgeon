require File.expand_path(File.dirname(__FILE__))+ '/../test_helper'

class UserMailerTest < ActionMailer::TestCase

  fixtures :all

  context "Mailer" do

    should "send notification when user account is created" do
      user = users(:wojciech)
      email =  UserMailer.created_notification(user).deliver!
      assert !ActionMailer::Base.deliveries.empty?
      assert_equal "wojciech@example.com", email.to.first
      assert_equal "Pivgeon - new account activation.", email.subject
      assert_match /#{ActionMailer::Base.default_url_options[:host]}\/users\/confirm\//, email.encoded
    end

  end

end
