require "test_helper"
class MovieTest < ActiveSupport::TestCase
  def setup
    @movie = movies(:movie_one)
  end

  test "should be valid" do
    assert @movie.valid?
  end

  test "title should be present" do
    @movie.title = ""
    assert_not @movie.valid?
  end

  test "duration should be positive" do
    @movie.duration = -10
    assert_not @movie.valid?
  end
end
