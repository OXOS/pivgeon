# coding: utf-8
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

    should_eventually "decode" do
    end

    should "parse headers" do
      headers = valid_params("daniel@example.com","wojciech@example.com","pivgeon@devel.pivgeon.com","xyz abc")['headers']
      parsed_headers = @message.send(:parse_headers,headers)
      assert_equal " =?UTF-8?Q?Daniel_Soko=C5=82owski?= <daniel@example.com>", parsed_headers["From"]
      assert_equal " =?UTF-8?Q?Daniel_Soko=C5=82owski?= <wojciech@example.com>", parsed_headers["To"]
      assert_equal " pivgeon@devel.pivgeon.com", parsed_headers["Cc"]
      assert_equal " <BANLkTi=aun99eo1S2Gfz6=vNOeZUKo4ePw@mail.gmail.com>", parsed_headers["Message-ID"]
    end

    should "get message id" do
      headers = @params['headers']
      message_id = @message.send(:get_message_id,headers)
      assert_equal " <BANLkTi=aun99eo1S2Gfz6=vNOeZUKo4ePw@mail.gmail.com>", message_id
    end
 


  end

end
