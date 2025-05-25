require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get home_index_url
    assert_response :success
  end

  test "should get show" do
    get home_show_url
    assert_response :success
  end

  test "should get create" do
    get home_create_url
    assert_response :success
  end

  test "should get edit" do
    get home_edit_url
    assert_response :success
  end

  test "should get update" do
    get home_update_url
    assert_response :success
  end

  test "should get destroy" do
    get home_destroy_url
    assert_response :success
  end
end
