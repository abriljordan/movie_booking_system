require "test_helper"

class Api::V1::MoviesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @movie1 = movies(:movie_one) # From test/fixtures/movies.yml
    @movie2 = movies(:movie_two)
    @soft_deleted_movie = movies(:deleted_movie)
  end

  test "should get index" do
    get api_v1_movies_path, as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal 2, json_response["data"].size
  end

  test "index should not return soft-deleted movies" do
    @soft_deleted_movie.discard # Soft delete the movie
    get api_v1_movies_path, as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    movie_ids = json_response["data"].map { |movie| movie["id"].to_i }
    assert_not_includes movie_ids, @soft_deleted_movie.id
  end

  test "index should return empty array if no movies exist" do
    Booking.delete_all    # Delete bookings first

    Showtime.delete_all # Delete dependent records first
    Movie.delete_all # Remove all movies from DB
    get api_v1_movies_path, as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal [], json_response["data"]
  end

  test "should show a movie" do
    get api_v1_movie_path(@movie1), as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal @movie1.title, json_response["data"]["attributes"]["title"]
  end

  test "should return 404 for non-existent movie" do
    get api_v1_movie_path(-1), as: :json
    assert_response :not_found
  end

  test "should return 404 for soft-deleted movie" do
    @soft_deleted_movie.discard # Soft delete the movie
    get api_v1_movie_path(@soft_deleted_movie), as: :json
    assert_response :not_found
  end
end
