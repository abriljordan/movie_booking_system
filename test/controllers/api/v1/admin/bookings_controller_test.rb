require "test_helper"

class Api::V1::Admin::BookingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:user_one)
    @booking = bookings(:booking_one)
    @headers = { "Authorization" => "Bearer #{JsonWebToken.encode(user_id: @admin.id, role: 'admin')}" }
  end

  test "authorize user can create a booking" do
    assert_difference("Booking.count", 1, "Booking was not created") do
      post api_v1_admin_bookings_path, params: {
        booking: {
          user_id: @admin.id,
          showtime_id: @booking.showtime_id,
          seats: 2,
          total_price: 50.0,
          status: "pending"
        }
      }, headers: @headers, as: :json
    end

    puts response.body # Print API response
    puts response.status # Print status code

    assert_response :created
  end

  test "authorize user can update a booking" do
    patch api_v1_admin_booking_path(@booking), params: { booking: { status: "confirmed" } }, headers: @headers, as: :json

    puts response.body # Print response
    puts response.status # Print status code

    assert_response :success
    @booking.reload
    assert_equal "confirmed", @booking.status, "Booking status was not updated"
  end

  test "authorize user can discard a booking" do
    delete api_v1_admin_booking_path(@booking), headers: @headers, as: :json

    puts response.body # Check response
    puts response.status # Check status

    assert_response :ok # Update expected status
    @booking.reload
    assert @booking.discarded?
  end

  test "authorize user can list all bookings" do
    get api_v1_admin_bookings_path, headers: @headers, as: :json

    json_response = JSON.parse(response.body)
    puts response.body # Print actual response
    puts json_response.class # Check if it's an array or hash

    assert json_response.is_a?(Array), "Expected response to be an array"
  end
end
