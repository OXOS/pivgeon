require File.expand_path(File.dirname(__FILE__))+ '/../test_helper'


class UsersControllerTest < ActionController::TestCase
  
  fixtures :all
  
  context "User" do
    
    should "activate his account" do
      user = users(:not_activated_user)
      User.any_instance.stubs(:check_token!).returns(nil)
      
      assert !user.status
      
      get :confirm, :id=>user.activation_code
      assert_response :success
      assert assigns(:user).status      
    end
    
    should "see information that his account is activated" do
      user = users(:not_activated_user)
      User.any_instance.expects(:activate!).returns(true)
      get :confirm, :id=>user.activation_code
      assert_select "div#box", "Your account has been activated"
    end
    
    should "see information that his account is not activated" do
      user = users(:not_activated_user)
      User.any_instance.expects(:activate!).returns(false)
      get :confirm, :id=>user.activation_code
      assert_select "div#box", "Sorry. Your account hasn't been activated."
    end
    
    should "see page 404 when try to access activation page using wrong token" do   
      get :confirm, :id=>"hakunamatata"
      assert_response 404
    end
    
  end
end
