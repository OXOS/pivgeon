require File.expand_path(File.dirname(__FILE__))+ '/../test_helper'


class UsersControllerTest < ActionController::TestCase
  
  fixtures :all
  
  context "User" do
    
    should "activate his account" do
      user = users(:not_activated_user)
      
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
    
  end
end
