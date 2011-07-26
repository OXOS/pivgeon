require File.expand_path(File.dirname(__FILE__))+ '/../test_helper'

class SendgridMessageTest < ActiveSupport::TestCase

  fixtures(:all)

  context "A message" do

    setup do
      @params = valid_params('wojciech@example.com','daniel@example.com')
      @message = SendgridMessage.new(@params)
    end
  
    
    should "detokenize email" do
      assert_equal "test@example.com", @message.send(:detokenize,"<test@example.com>")
      assert_equal "test@example.com", @message.send(:detokenize,"test@example.com")
      assert_equal "test@example.com", @message.send(:detokenize,"Test Example <test@example.com>")            
    end
 


  end

end
