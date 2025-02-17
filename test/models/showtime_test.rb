require "test_helper"

class ShowtimeTest < ActiveSupport::TestCase
  def setup
    @showtime = showtimes(:showtime_one)
  end

  test "should be valid" do
    assert @showtime.valid?
  end
end
