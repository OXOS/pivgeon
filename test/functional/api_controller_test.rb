require File.expand_path(File.dirname(__FILE__))+ '/../test_helper'

class ApiControllerTest < ActionController::TestCase
  include ActionController::Assertions::PivGeonAssertions
  fixtures :all
  
  context "A controller" do  
            
    setup do   
      mock_requests
      @user = users(:wojciech)
      @owner = users(:daniel)            
    end

    should "create story" do            
      ob_proxy = mock("object_proxy")
      ob_proxy.expects(:find_by_email).with("wojciech@example.com").returns(@user)
      User.expects(:active).returns(ob_proxy)
      Story.expects(:valid_subject_format?).with("[GeePivoMailin] Subject").returns(true)
      Story.expects(:parse_subject).with("[GeePivoMailin] Subject").returns({:name=>"Subject",:project_name=>"GeePivoMailin"})
      Story.expects(:token=)
      Story.any_instance.expects(:save!).returns(true)
      Story.expects(:send_notification)
      
      post :create, valid_params(@user.email,"daniel@example.com","[GeePivoMailin] Subject")     
      assert_response 200
    end

    should "not create story" do
      ob_proxy = mock("object_proxy")
      ob_proxy.expects(:find_by_email).with("wojciech@example.com").returns(@user)
      User.expects(:active).returns(ob_proxy)
      Story.expects(:valid_subject_format?).with("[GeePivoMailin] Subject").returns(true)
      Story.expects(:parse_subject).with("[GeePivoMailin] Subject").returns({:name=>"Subject",:project_name=>"GeePivoMailin"})
      Story.expects(:token=)
      Story.any_instance.expects(:save!).raises(ActiveRecord::RecordNotSaved)
      Story.expects(:send_notification)
      
      post :create, valid_params(@user.email,"daniel@example.com","[GeePivoMailin] Subject")
      assert_response 200, "Invalid data"
    end
      
    should "create user" do
      User.expects(:parse_message).returns("some attrs fake")
      user_mock = mock("user")
      user_mock.expects(:save!).returns(true)
      User.expects(:find_or_build).with("some attrs fake").returns(user_mock)
      User.expects(:send_notification)
      post :create, valid_params("annonymous@example.com",CLOUDMAILIN_EMAIL_ADDRESS,"123123131")
      assert_response 200
    end
    
    should "not create user" do
      User.expects(:parse_message).returns("some attrs fake")
      user_mock = mock("user")
      user_mock.expects(:save!).raises(ActiveRecord::RecordNotSaved)
      User.expects(:find_or_build).with("some attrs fake").returns(user_mock)
      User.expects(:send_notification)
      post :create, valid_params("annonymous@example.com",CLOUDMAILIN_EMAIL_ADDRESS,"123123131")
      assert_response 200, "Invalid data"
    end
      
  end
  
end  
