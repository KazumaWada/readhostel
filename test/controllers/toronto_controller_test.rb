require "test_helper"

class TorontoControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get toronto_show_url
    assert_response :success
  end
end
