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
      Story.expects(:get_project_and_story_name).with("Subject","GeePivoMailin@pivgeon.com").returns(["GeePivoMailin"," Subject"])
      Story.expects(:token=)
      Story.any_instance.expects(:save!).returns(true)
      Story.expects(:send_notification)
      
      post :create, valid_params(@user.email,@owner.email,"GeePivoMailin@pivgeon.com","Subject")     
      assert_response 200
    end

    should "not create story" do
      ob_proxy = mock("object_proxy")
      ob_proxy.expects(:find_by_email).with("wojciech@example.com").returns(@user)
      User.expects(:active).returns(ob_proxy)
      Story.expects(:get_project_and_story_name).with("Subject","GeePivoMailin@pivgeon.com").returns(["GeePivoMailin"," Subject"])
      Story.expects(:token=)
      Story.any_instance.expects(:save!).raises(ActiveRecord::RecordNotSaved)
      Story.expects(:send_notification)
      
      post :create, valid_params(@user.email,@owner.email,"GeePivoMailin@pivgeon.com","Subject")
      assert_response 200, "Invalid data"
    end
      
    should "create user" do
      User.expects(:parse_message).returns("some attrs fake")
      user_mock = mock("user")
      user_mock.expects(:save!).returns(true)
      User.expects(:find_or_build).with("some attrs fake").returns(user_mock)
      User.expects(:send_notification)
      post :create, valid_params("annonymous@example.com",CLOUDMAILIN_EMAIL_ADDRESS,nil,"123123131")
      assert_response 200
    end
    
    should "not create user" do
      User.expects(:parse_message).returns("some attrs fake")
      user_mock = mock("user")
      user_mock.expects(:save!).raises(ActiveRecord::RecordNotSaved)
      User.expects(:find_or_build).with("some attrs fake").returns(user_mock)
      User.expects(:send_notification)
      post :create, valid_params("annonymous@example.com",CLOUDMAILIN_EMAIL_ADDRESS,nil,"123123131")
      assert_response 200, "Invalid data"
    end

	should "return status 200 when 'send_notification' raises exception" do
      Story.stubs(:send_notification).raises(ArgumentError)
      post :create, valid_params(@user.email,"daniel@example.com",nil,"[GeePivoMailin] Subject")
      assert_response 200
    end
  end
  
end  
