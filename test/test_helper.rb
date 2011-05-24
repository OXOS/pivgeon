ENV["RAILS_ENV"] = "test"
ENV['RUBYOPT'] = "-W0"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require "ruby-debug"


class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
#  fixtures :all

  # Add more helper methods to be used by all tests here...
      

  def valid_params(from, to, subject="[GeePivoMailin] Story 1")
    {"html"=>"description<br/>", 
     "plain"=>"description", 
     "disposable"=>"", 
     "from"=>"wojciech@example.com", 
     "signature"=>"60d30a03373fb7366e49920b333cf44e", 
     "subject"=>subject, 
     "to"=>"<dfba89c3c1ec17e81304@cloudmailin.net>", 
     "message"=>"Received: by qwj8 with SMTP id 8so3681152qwj.4\r\n        for <b06e829748e4a3c9cea9@cloudmailin.net>; Sun, 03 Apr 2011 11:48:53 -0700 (PDT)\r\nMIME-Version: 1.0\r\nReceived: by 10.224.200.195 with SMTP id ex3mr5033699qab.229.1301856533092;\r\n Sun, 03 Apr 2011 11:48:53 -0700 (PDT)\r\nReceived: by 10.224.37.81 with HTTP; Sun, 3 Apr 2011 11:48:53 -0700 (PDT)\r\nDate: Sun, 3 Apr 2011 20:48:53 +0200\r\nMessage-ID: <BANLkTimSJh85TDNCn0RNH_YH5EHggnDAfw@mail.gmail.com>\r\nSubject: #{subject}\r\nFrom: =?UTF-8?Q?Daniel_Soko=C5=82owski?= <#{from}>\r\nTo: =?UTF-8?Q?Daniel_Soko=C5=82owski?= <#{to}>\r\nCc: b06e829748e4a3c9cea9@cloudmailin.net\r\nContent-Type: multipart/alternative; boundary=20cf3010edcf3419bd04a0081821\r\n\r\n--20cf3010edcf3419bd04a0081821\r\nContent-Type: text/plain; charset=UTF-8\r\n\r\n\r\n\r\n--20cf3010edcf3419bd04a0081821\r\nContent-Type: text/html; charset=UTF-8\r\n\r\n<br>\r\n\r\n--20cf3010edcf3419bd04a0081821--"}
  end
  

  def new_story_attrs(user_id,owner_email)
    {:user_id=>user_id,
     :name=>"Story 1", 
     :description=>"description", 
     :project_name=>"GeePivoMailin",
     :owner_email=>owner_email
     }
  end
  
  def test_presence_of(elem,param)
    elem.send("#{param}=",nil)
    assert_false elem.save
  end
  
  def pivotal_request
    "<story>
      <story-type>feature</story-type>
      <name>Story 1</name>
      <requested-by>wojciech</requested-by>
      <owned-by>daniel</owned-by>
    </story>"
  end
  
  def pivotal_story_response
    '<?xml version="1.0" encoding="UTF-8"?>
    <story>
      <id type="integer">100001</id>
      <project_id type="integer">147449</project_id>
      <story_type>feature</story_type>
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
  
  def pivotal_memberships_response
    '<?xml version="1.0" encoding="UTF-8"?>
    <memberships type="array">
      <membership>
        <id>1</id>
        <person>
          <email>wojciech@example.com</email>
          <name>wojciech</name>
          <initials>WK</initials>
        </person>
        <role>Owner</role>
        <project>
          <id>147449</id>
          <name>Project 1</name>
        </project>
      </membership>
      <membership>
        <id>2</id>
        <person>
          <email>daniel@example.com</email>
          <name>daniel</name>
          <initials>DS</initials>
        </person>
        <role>Member</role>
        <project>
          <id>147449</id>
          <name>Project 1</name>
        </project>
      </membership>
    </memberships>
  '
  end
  
  def pivotal_projects_response
    ' <?xml version="1.0" encoding="UTF-8"?>
    <projects type="array">
      <project>
        <id>147449</id>
        <name>GeePivoMailin</name>
        <iteration_length type="integer">2</iteration_length>
        <week_start_day>Monday</week_start_day>
        <point_scale>0,1,2,3</point_scale>
        <velocity_scheme>Average of 4 iterations</velocity_scheme>
        <current_velocity>10</current_velocity>
        <initial_velocity>10</initial_velocity>
        <number_of_done_iterations_to_show>12</number_of_done_iterations_to_show>
        <labels>shields,transporter</labels>
        <allow_attachments>true</allow_attachments>
        <public>false</public>
        <use_https>true</use_https>
        <bugs_and_features_are_estimatable>false</bugs_and_features_are_estimatable>
        <commit_mode>false</commit_mode>
        <last_activity_at type="datetime">2010/01/16 17:39:10 CST</last_activity_at>
        <memberships type="array">
          <membership>
            <id>1</id>
            <person>
              <email>wojciech@example.com</email>
              <name>wojciech</name>
              <initials>WK</initials>
            </person>
            <role>Owner</role>
            <project>
              <id>147449</id>
              <name>Project 1</name>
            </project>
          </membership>
          <membership>
            <id>2</id>
            <person>
              <email>daniel@example.com</email>
              <name>daniel</name>
              <initials>DS</initials>
            </person>
            <role>Member</role>
            <project>
              <id>147449</id>
              <name>Project 1</name>
            </project>
          </membership>
        </memberships>
      </project>      
    </projects>
  '
  end
  
  def pivotal_memberships_response_with_no_records
    '<?xml version="1.0" encoding="UTF-8"?>
    <memberships type="array">
    </memberships>
  '
  end
  
  def mock_requests()
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get("/services/v3/projects.xml", 
                {"Accept"=>"application/xml", "X-TrackerToken"=>'123123131'}, 
                pivotal_projects_response,
                200)
      mock.get("/services/v3/projects.xml", 
                {"Accept"=>"application/xml", "X-TrackerToken"=>'12345678'}, 
                pivotal_projects_response,
                200) 
      mock.get("/services/v3/projects.xml", 
                {"Accept"=>"application/xml", "X-TrackerToken"=>'111111111'}, 
                pivotal_projects_response,
                200)  
      mock.get("/services/v3/projects.xml", 
                {"Accept"=>"application/xml", "X-TrackerToken"=>''}, 
                nil,
                401)
      mock.get("/services/v3/projects.xml", 
                {"Accept"=>"application/xml", "X-TrackerToken"=>'1'}, 
                nil,
                401)      
      mock.post("/services/v3/projects/147449/stories.xml", 
                {"Content-Type"=>"application/xml", "X-TrackerToken"=>'12345678'}, 
                pivotal_story_response,
                201)
      mock.get("/services/v3/projects/147449/memberships.xml", 
                {"Accept"=>"application/xml", "X-TrackerToken"=>'12345678'}, 
                pivotal_memberships_response,
                201)     
      mock.post("/services/v3/projects//stories.xml", 
                {"Content-Type"=>"application/xml", "X-TrackerToken"=>'12345678'}, 
                nil,
                500)
      mock.post("/services/v3/projects/404404404/stories.xml", 
                {"Content-Type"=>"application/xml", "X-TrackerToken"=>'12345678'}, 
                nil,
                404)    
       mock.get("/services/v3/projects/404404404/memberships.xml", 
                {"Accept"=>"application/xml", "X-TrackerToken"=>'12345678'}, 
                pivotal_memberships_response,
                201)     
      mock.get("/services/v3/projects//memberships.xml", 
                {"Accept"=>"application/xml", "X-TrackerToken"=>'12345678'}, 
                nil,
                500)
      mock.get("/services/v3/projects.xml", 
                {"Accept"=>"application/xml", "X-TrackerToken"=>'12345678'}, 
                pivotal_projects_response,
                200)      
    end
  end
          
end


module ActionController
  module Assertions
    module PivGeonAssertions
      def assert_notification(subject,&block)
        assert_difference("ActionMailer::Base.deliveries.count") do  
          block.call
          assert_response 200
          assert_equal subject, ActionMailer::Base.deliveries.last.subject
        end    
      end
    end
  end
end

module ActionDispatch
  module Assertions
    module PivGeonAssertions
      def assert_notification(subject,&block)
        assert_difference("ActionMailer::Base.deliveries.count") do  
          block.call                    
          assert_equal 200, status
          assert_equal subject, ActionMailer::Base.deliveries.last.subject
        end    
      end
    end
  end
end