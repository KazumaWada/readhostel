require "test_helper"

class DraftsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get drafts_index_url
    assert_response :success
  end

  test "should get edit" do
    get drafts_edit_url
    assert_response :success
  end

  test "should get update" do
    get drafts_update_url
    assert_response :success
  end
end
