require File.expand_path(File.dirname(__FILE__))+ '/../test_helper'


class UsersControllerTest < ActionController::TestCase

  fixtures :all

  context "A user" do

    should "see 'Create user' form" do
      user = User.new
      User.expects(:new).returns(user)
      get :new
      assert_response :success
    end

    should "see confirmation" do
      get :show, :id => 1
      assert_response :success
    end

    should "create new account" do
      user = User.new
      User.expects(:new).returns(user)
      user.expects(:save).returns(true)
      @controller.expects(:user_path).with(user).returns("/show/1")
      post :create, :email => "name@example.com", :token => "12345678"
      assert_redirected_to "/show/1"
    end

    should "not create new account" do
      user = User.new
      User.expects(:new).returns(user)
      user.expects(:save).returns(false)
      post :create, :email => "name@example.com", :token => "12345678"
      assert_template "/new"
    end

  end
end
