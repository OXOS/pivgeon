require File.expand_path(File.dirname(__FILE__))+ '/../test_helper'

class NotifierTest < ActionMailer::TestCase
  
  fixtures :all

  context "Notifier" do 
    
    setup do
      @user = users(:wojciech)
    end

    should "send notification" do        
      params = valid_params  "wojciech@example.com", "daniel@example.com", "", "Story name"
      message = SendgridMessage.new(params)
      email =  Notifier.unauthorized_access(message).deliver!
      assert !ActionMailer::Base.deliveries.empty?
      assert_equal "wojciech@example.com", email.to.first
      assert_equal "Re: Story name", email.subject
      assert_match /You tried to create new story. Unfortunatelly the story hasn't been created due to following errors:/, email.encoded
      assert_match /Unauthorized access/, email.encoded
    end

    
  end
  
end
