require "test_helper"

class Api::V1::ShowtimesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @showtime1 = showtimes(:showtime_one) # From test/fixtures/showtimes.yml
    @showtime2 = showtimes(:showtime_two)
  end

  test "should get index" do
    get api_v1_showtimes_path, as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal 2, json_response["data"].size
  end

  test "should show a showtime" do
    get api_v1_showtime_path(@showtime1), as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    expected_time = @showtime1.start_time.iso8601(3) # Ensure milliseconds are included
    actual_time = json_response["data"]["attributes"]["start_time"]

    assert_equal expected_time, actual_time
  end

  test "should return 404 for non-existent showtime" do
    get api_v1_showtime_path(-1), as: :json
    assert_response :not_found
  end
end
