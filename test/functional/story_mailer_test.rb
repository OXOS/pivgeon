require File.expand_path(File.dirname(__FILE__))+ '/../test_helper'

class StoryMailerTest < ActionMailer::TestCase
  
  fixtures :all

  context "Mailer" do 
    
    setup do
      @user = users(:wojciech)
      @story = Story.new(:owned_by=>"daniel",:requested_by=>"wojciech",:name=>"Story nr 1",:user_id=>@user.id)
    end
    
    should "send notification when story is created" do
      @story.stubs(:id).returns(12345)
      @story.stubs(:name).returns("Story nr 1")
      email =  StoryMailer.created_notification(@story,nil,{:message_subject => "[test] Story name"}).deliver!
      assert !ActionMailer::Base.deliveries.empty?
      assert_equal "wojciech@example.com", email.to.first
      assert_equal "Re: [test] Story name", email.subject
      assert_match /You have created new story <a href=\"https:\/\/www.pivotaltracker.com\/story\/show\/12345\">Story nr 1<\/a>./, email.encoded
    end
    
    context "when story is not created" do
    
      should "send notification which contains error messages" do
        @story.errors.add(:base1, "message 1")
        @story.errors.add(:base2, "message 2")

        email =  StoryMailer.not_created_notification(@story,nil,{:message_subject => "[test] Story name"}).deliver!
        assert !ActionMailer::Base.deliveries.empty?
        assert_equal "wojciech@example.com", email.to.first
        assert_equal "Re: [test] Story name", email.subject
        assert_match /You tried to create new story. Unfortunatelly the story hasn't been created due to following errors:/, email.encoded
        assert_match /message 1/, email.encoded
        assert_match /message 2/, email.encoded
      end
      
      should "send notification which contains custom error message" do        
	  	message = OpenStruct.new({ :to => ["daniel@example.com"], :from => ["wojciech@example.com"], :body => 'description', :subject => " Story name", :headers => {}})
        email =  StoryMailer.not_created_notification(message,"This is custom error message",{:message_subject => "[test] Story name"}).deliver!
        assert !ActionMailer::Base.deliveries.empty?
        assert_equal "wojciech@example.com", email.to.first
        assert_equal "Re: [test] Story name", email.subject
        assert_match /You tried to create new story. Unfortunatelly the story hasn't been created due to following errors:/, email.encoded
        assert_match /This is custom error message/, email.encoded
      end
      
    end
    
  end
  
end
