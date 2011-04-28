require File.expand_path(File.dirname(__FILE__))+ '/../test_helper'

class StoryMailerTest < ActionMailer::TestCase
  
  fixtures :all

  context "Mailer" do 
    
    setup do
      @user = users(:wojciech)
      @story = Story.new(:owned_by=>"daniel",:requested_by=>"wojciech",:name=>"Story nr 1",:user_id=>@user.id)
    end
    
    context "when story is created" do
      
      should "send notification for story creator" do
        @story.stubs(:id).returns(12345)
        @story.stubs(:name).returns("Story nr 1")
        email =  StoryMailer.created_for_creator(@story).deliver!
        assert !ActionMailer::Base.deliveries.empty?
        assert_equal "wojciech@example.com", email.to.first
        assert_equal "GeePivoMailin: new story created", email.subject
        assert_match /You have created new story <a href=\"https:\/\/www.pivotaltracker.com\/story\/show\/12345\">Story nr 1<\/a>./, email.encoded
      end
      
      should "send notification for story owner" do
        @story.stubs(:id).returns(12345)
        @story.stubs(:name).returns("Story nr 1")
        email =  StoryMailer.created_for_owner(@story).deliver!
        assert !ActionMailer::Base.deliveries.empty?
        assert_equal "wojciech@example.com", email.to.first
        assert_equal "GeePivoMailin: new story assigned to you", email.subject
        assert_match /User #{@story.user.email} has created new story #{@story.name} and assigned it to you./, email.encoded
      end
      
    end
            
    context "when story is not created" do

      should "receive notification which contains error messages" do
        @story.errors.add(:base1, "message 1")
        @story.errors.add(:base2, "message 2")

        email =  StoryMailer.not_created_for_creator(@story).deliver!
        assert !ActionMailer::Base.deliveries.empty?
        assert_equal "wojciech@example.com", email.to.first
        assert_equal "GeePivoMailin: error creating new story", email.subject
        assert_match /You tried to create new story. Unfortunatelly the story hasn't been created due to following errors:/, email.encoded
        assert_match /message 1/, email.encoded
        assert_match /message 2/, email.encoded
      end

      should "receive notification which contains custom error message" do        
        message =  Mail.new(valid_params("wojciech@example.com","daniel@example.com")['message'])
        email =  StoryMailer.not_created_for_creator(message,"This is custom error message").deliver!
        assert !ActionMailer::Base.deliveries.empty?
        assert_equal "wojciech@example.com", email.to.first
        assert_equal "GeePivoMailin: error creating new story", email.subject
        assert_match /You tried to create new story. Unfortunatelly the story hasn't been created due to following errors:/, email.encoded
        assert_match /This is custom error message/, email.encoded
      end       
      
    end
    
  end
  
end
