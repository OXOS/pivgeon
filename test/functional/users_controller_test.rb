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



    should "create new account" do
      user = User.new
      User.expects(:new).returns(user)
      user.expects(:save).returns(true)
      post :create, :email => "name@example.com", :token => "12345678"
      assert_template :show
      assert_equal "Thank you! Please confirm your email by clicking the link we've just sent you.", flash[:notice]
    end

    should "not create new account" do
      user = User.new
      User.expects(:new).returns(user)
      user.expects(:save).returns(false)    
      post :create, :email => "name@example.com", :token => "12345678"
      assert_template "/new"
    end

    should "activate his account" do
      user = users(:inactive)
      User.any_instance.stubs(:check_token!).returns(nil)

      assert !user.status

      get :confirm, :id=>user.activation_code
      assert_response :success
      assert assigns(:user).status
    end

    should "see information that his account is activated" do
      user = users(:inactive)
      User.any_instance.expects(:activate!).returns(true)
      get :confirm, :id=>user.activation_code
      assert_select "p", /Your account has been activated/
    end

    should "see information that his account is not activated" do
      user = users(:inactive)
      User.any_instance.expects(:activate!).returns(false)
      get :confirm, :id=>user.activation_code
      assert_select "p", /Sorry. Your account hasn't been activated./
    end

    should "see page 404 when try to access activation page using wrong token" do
      get :confirm, :id=>"hakunamatata"
      assert_response 404
#      assert @response.body.include?("The page you were looking for doesn't exist.")
      assert_template "public/404.html"
    end

  end
end
