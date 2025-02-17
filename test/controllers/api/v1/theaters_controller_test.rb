require "test_helper"

class Api::V1::TheatersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @theater = theaters(:theater_one) # Assuming you have a theater fixture
  end

  test "should list all theaters" do
    get api_v1_theaters_path
    assert_response :success
  end

  test "should show a single theater" do
    get api_v1_theater_path(@theater)
    assert_response :success
  end
end
