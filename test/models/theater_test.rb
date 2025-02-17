# test/models/theater_test.rb
require "test_helper"

class TheaterTest < ActiveSupport::TestCase
  def setup
    @theater = theaters(:theater_one)
  end

  test "should be valid" do
    assert @theater.valid?
  end

  test "total seats should be positive" do
    @theater.total_seats = 0
    assert_not @theater.valid?
  end
  test "name should be present" do
    @theater.name = ""
    assert_not @theater.valid?
  end
end
