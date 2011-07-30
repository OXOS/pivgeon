require File.expand_path(File.dirname(__FILE__))+ '/../test_helper'

class UserTest < ActiveSupport::TestCase
  
  fixtures :all
  
  context "User" do
    
    should "validate email presence" do
    end

    should "validate email uniqueness" do
    end

    should "validate token presence" do
    end

    should "validate if given token is correct pivotal token" do
    end
    
  end

end
