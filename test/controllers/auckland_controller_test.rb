require "test_helper"

class AucklandControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get auckland_show_url
    assert_response :success
  end
end
