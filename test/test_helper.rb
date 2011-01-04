ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
#  fixtures :all

  # Add more helper methods to be used by all tests here...
  
  def mail_params
    {:message=>"message", :plain=>"plaint", :html=>"html", :to=>"to@example.com", :from=>"from@example.com", :subject=>"Story 1"}
  end
  
  def story_attrs
    {:story_type=>"chore",:name=>"Story 1", :requested_by=>"daniel", :owned_by=>"daniel"}
  end
  
  def test_presence_of(elem,param)
    elem.send("#{param}=",nil)
    assert_false elem.save
  end
  
  def pivotal_request
    "<story>
      <story-type>chore</story-type>
      <name>Story 1</name>
      <requested-by>daniel</requested-by>
      <owned-by>daniel</owned-by>
    </story>"
  end
  
  def pivotal_response
    '<?xml version="1.0" encoding="UTF-8"?>
    <story>
      <id type="integer">100001</id>
      <project_id type="integer">147449</project_id>
      <story_type>chore</story_type>
      <url>http://www.pivotaltracker.com/story/show/100001</url>
      <estimate type="integer">-1</estimate>
      <current_state>unscheduled</current_state>
      <description></description>
      <name>Story1</name>
      <requested_by>daniel</requested_by>
      <owned_by>daniel</owned_by>
      <created_at type="datetime">2008/12/10 00:00:00 UTC</created_at>
    </story>'
  end
  
end
