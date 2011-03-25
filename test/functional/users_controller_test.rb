require File.expand_path(File.dirname(__FILE__))+ '/../test_helper'


class UsersControllerTest < ActionController::TestCase
  
  fixtures :all
  
  # Replace this with your real tests.
  context "User" do
    
    should "activate his account" do
      user = users(:not_activated_user)
      
      assert !user.status
      
      get :confirm, :id=>user.activation_code
      assert_response :success
      assert assigns(:user).status
    end
    
  end
end
