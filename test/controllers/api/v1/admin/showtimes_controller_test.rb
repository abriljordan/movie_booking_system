require "test_helper"

class Api::V1::Admin::ShowtimesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @admin = users(:user_one) # Make sure to have an admin user fixture
    @movie = movies(:movie_one)
    @theater = theaters(:theater_one)
    @showtime = showtimes(:showtime_one)

    @headers = { "Authorization" => "Bearer #{JsonWebToken.encode(user_id: @admin.id, role: 'admin')}" }
  end

  test "admin can create showtime" do
    post api_v1_admin_showtimes_path, params: {
      showtime: {
        start_time: Time.now,
        end_time: Time.now + 2.hours,
        movie_id: @movie.id,
        theater_id: @theater.id
      }
    }, headers: @headers

    assert_response :created
  end

  test "admin can update showtime" do
    patch api_v1_admin_showtime_path(@showtime), params: {
      showtime: { start_time: Time.now + 1.hour }
    }, headers: @headers

    assert_response :ok
  end

  test "admin can soft delete showtime" do
    delete api_v1_admin_showtime_path(@showtime), headers: @headers
    assert_response :ok
    assert_not_nil @showtime.reload.discarded_at
  end
end
