require "test_helper"

class BookingTest < ActiveSupport::TestCase
  def setup
    @booking = bookings(:booking_one)
  end

  test "should be valid" do
    assert @booking.valid?
  end

  test "seats should be greater than 0" do
    @booking.seats = 0
    assert_not @booking.valid?
  end
end
