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
  
  def set_users
    new_settings = {
      'wojciech@example.com' => {
                                  'name' => 'wojciech',
                                  'token' => '12345678'
                                },
      'daniel@example.com' => {
                                  'name' => 'daniel',
                                  'token' => '87654321'
                                }                          
    }    
    Object.send(:remove_const, 'GEEPIVO_USERS')
    Object.const_set('GEEPIVO_USERS',new_settings)
  end
  
  def stub_story_headers headers
    Story.stubs(:headers).returns(headers)
  end
  
  def incoming_params from, to
    {"html"=>"", 
     "plain"=>"", 
     "disposable"=>"", 
     "from"=>"wojciech@example.com", 
     "signature"=>"60d30a03373fb7366e49920b333cf44e", 
     "subject"=>"Story 1", 
     "to"=>"<dfba89c3c1ec17e81304@cloudmailin.net>", 
     "message"=>"Received: (wp-smtpd smtp.wp.pl 22222 invoked from network); 11 Jan 2011 13:45:23 +0100\r\nReceived: from out.poczta.wp.pl (HELO localhost) ([222.22.222.222])\r\n(envelope-sender <#{from}>)\r\n          by smtp.wp.pl (WP-SMTPD) with SMTP\r\nfor <#{to}>; 11 Jan 2011 13:45:23 +0100\r\nDate: Tue, 11 Jan 2011 13:45:23 +0100\r\nFrom: =?ISO-8859-2?Q?wojciech?= <#{from}>\r\nTo: daniel <#{to}>\r\nCc: dfba89c3c1ec17e81304 <dfba89c3c1ec17e81304@cloudmailin.net>\r\nSubject: Story 1\r\nMessage-ID: <4d2c50e315e556.43793632@wp.pl>\r\nMIME-Version: 1.0\r\nContent-Type: text/plain; charset=iso-8859-2\r\nContent-Transfer-Encoding: 8bit\r\nContent-Disposition: inline\r\n"}
  end
  
  def new_story_attrs(requested_by,owned_by,token)
    {:story_type=>"chore",:name=>"Story 1", :requested_by=>requested_by, :owned_by=>owned_by, :token=>token}
  end
  
  def test_presence_of(elem,param)
    elem.send("#{param}=",nil)
    assert_false elem.save
  end
  
  def pivotal_request
    "<story>
      <story-type>chore</story-type>
      <name>Story 1</name>
      <requested-by>wojciech</requested-by>
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
      <requested_by>wojciech</requested_by>
      <owned_by>daniel</owned_by>
      <created_at type="datetime">2008/12/10 00:00:00 UTC</created_at>
    </story>'
  end
  
end
