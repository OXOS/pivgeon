require File.expand_path(File.dirname(__FILE__))+ '/../test_helper'
require "ostruct"

class UserTest < ActiveSupport::TestCase
  
  fixtures :all
  
  context "User" do

    setup do
      mock_requests()
    end

    should "status should default to false" do
      user = User.create :email => "some.user.1@example.com", :token => "12345678"
      assert !user.new_record?
      assert_equal false, user.status
    end

    should "activate" do
      user = User.create :email => "some.user.2@example.com", :token => "12345678"
      assert !user.new_record?
      assert_equal false, user.status

      user.activate!
      assert_equal true, user.status
    end

    should "send activation email on create" do
      user = User.new :email => "some.user.3@example.com", :token => "12345678"
      user.expects(:send_activation_link)
      assert user.save
    end

    should "validate email presence" do
      user = User.create :email => nil, :token => "12345678"
      assert_equal "Email can't be blank", user.errors['email'].first
    end

    should "validate email uniqueness" do
      user = User.create :email => "daniel@example.com"
      assert_equal "Email address is already taken", user.errors['email'].first
    end

    should "validate token presence" do
      user = User.create
      assert_equal "Token can't be blank", user.errors['token'].first
    end

    should "validate if given token is correct pivotal token" do
      Net::HTTP.stubs(:request).returns(OpenStruct.new(:code => "401"))
      user = User.create :email => nil, :token => "12345678"
      assert_equal "Token is invalid", user.errors['token'].first
    end
    
  end

end
