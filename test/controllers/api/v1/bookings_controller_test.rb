require "test_helper"

class Api::V1::BookingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:user_one)
    @admin = users(:user_two)
    @showtime = showtimes(:showtime_one)
    @booking = bookings(:booking_one)
    @auth_headers = { "Authorization" => "Bearer #{JsonWebToken.encode(user_id: @user.id, role: 'customer')}" }
  end

  test "should require authentication to get bookings" do
    get api_v1_user_bookings_path(@user)
    assert_response :unauthorized
  end

  test "should get index for authenticated user" do
    get api_v1_user_bookings_path(@user), headers: @auth_headers
    assert_response :success
  end

  test "should create a booking for authenticated user" do
    assert_difference("Booking.count", 1) do
      post api_v1_user_bookings_path(@user), params: {
        booking: { showtime_id: @showtime.id, seats: 2, total_price: 30.0 }
      }, headers: @auth_headers
      puts @response.body
    end
    assert_response :created
    puts @response.body
  end

  test "should not create booking without authentication" do
    post api_v1_user_bookings_path(@user), params: { booking: { showtime_id: @showtime.id, seats: 2 } }
    assert_response :unauthorized
  end

  test "should update booking for authenticated user" do
    booking = Booking.find_by(id: @booking.id) # Debugging
    puts booking.inspect # Debugging
    assert_not_nil booking, "Booking should exist before update"

    patch api_v1_user_booking_path(@user, @booking), params: { booking: { seats: 3 } }, headers: @auth_headers
    puts response.body # Debugging output
    assert_response :success
    @booking.reload
    assert_equal 3, @booking.seats
  end

  test "should not update booking without authentication" do
    patch api_v1_user_booking_path(@user, @booking), params: { booking: { seats: 3 } }
    assert_response :unauthorized
  end

  test "should delete booking for authenticated user" do
    assert Booking.exists?(@booking.id) # Debugging check
    assert_difference("Booking.count", -1) do
      delete api_v1_user_booking_path(@user, @booking), headers: @auth_headers
    end
    assert_response :no_content
  end

  test "should not delete booking without authentication" do
    delete api_v1_user_booking_path(@user, @booking)
    assert_response :unauthorized
  end
end
