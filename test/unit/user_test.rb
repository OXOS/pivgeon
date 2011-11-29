require File.expand_path(File.dirname(__FILE__))+ '/../test_helper'
require "ostruct"

class UserTest < ActiveSupport::TestCase

  fixtures :all

  context "User" do

    setup do
      mock_requests()
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
      user = User.create :email => nil, :token => "765378905"
      assert_equal "Token is invalid", user.errors['token'].first
    end

  end

end
