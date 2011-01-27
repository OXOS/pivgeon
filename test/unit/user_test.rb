require 'test_helper'

class UserTest < ActiveSupport::TestCase
  
  context "A new user" do
    
    should validate_presence_of(:name)
    should validate_presence_of(:token)
    should validate_presence_of(:email)
    
    
  end
  
end
