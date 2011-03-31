require File.expand_path(File.dirname(__FILE__))+ '/../../test_helper'

class ApplicationHelperTest < ActionView::TestCase
  
  test "display_all_error_messages" do
    u = User.new()
    u.errors.add(:token,"message 1")
    u.errors.add(:email,"message 2")
    assert_equal"<li>message 1</li>", display_all_error_messages(u,:token)
    assert_equal"<li>message 2</li>", display_all_error_messages(u,:email)
  end
  
end
