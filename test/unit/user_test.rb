require 'test_helper'

class UserTest < ActiveSupport::TestCase
  
  context "it" do
    
    should validate_presence_of(:name)
    should validate_presence_of(:token)
    should validate_presence_of(:email)
    should validate_uniqueness_of(:email)
    
    should "create new user" do
      assert User.create(:name=>"test",:email=>"test@example.com", :token=>"12345678")
    end
    
    should "parse incoming message" do
      message = Mail.new(incoming_params("wojciech@example.com","cloudmailin@example.com","wojciech,12345678")['message'])
      assert_equal({:name=>"wojciech",:email=>"wojciech@example.com",:token=>"12345678"}, User.parse_message(message))
    end
    
  end
  
end
