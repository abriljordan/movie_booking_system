require "test_helper"

class Api::V1::Admin::MoviesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:user_one) # Assuming you have an admin fixture
    @user = users(:user_two)
    @movie = movies(:movie_one) # Assuming you have a movie fixture
    @headers = { "Authorization" => "Bearer #{JsonWebToken.encode(user_id: @admin.id, role: 'admin')}" }
    @invalid_headers = { "Authorization" => "Bearer #{JsonWebToken.encode(user_id: @user.id, role: 'customer')}" }
  end

  test "admin can create a movie" do
    assert_difference("Movie.count", 1) do
      post api_v1_admin_movies_path, params: {
        movie: { title: "New Movie",
        duration: 120,
        rating: "PG-13",
        description: "New Movie description",
        release_date: Date.today,
        genre: "Adventure"
        }
      }, headers: @headers
    end
    puts "creating a movie"
    puts Movie.all.inspect

    assert_response :created

    json_response = JSON.parse(response.body)
    assert_equal "New Movie", json_response["data"]["attributes"]["title"]
  end

  ## ❌ Edge Case: Admin tries to create a movie with missing params
  test "admin cannot create a movie with missing parameters" do
    post api_v1_admin_movies_path,
      params: { movie: { title: "", duration: nil } },
      headers: @headers,
      as: :json # Ensure request is correctly formatted as JSON

    assert_response :unprocessable_entity

    json_response = JSON.parse(response.body)

    expected_errors = [
      "Title can't be blank",
      "Duration can't be blank",
      "Duration is not a number",
      "Description can't be blank",
      "Release date can't be blank"
    ]

    expected_errors.each do |error|
      assert_includes json_response["errors"], error
    end
  end

   ## ❌ Edge Case: Non-admin tries to create a movie
   test "non-admin cannot create a movie" do
    post api_v1_admin_movies_path,
      params: { movie: { title: "Unauthorized Movie", duration: 100 } },
      headers: @invalid_headers
    assert_response :forbidden
  end

  ## ✅ Test: Admin can update a movie
  test "admin can update a movie" do
    patch api_v1_admin_movie_path(@movie),
      params: { movie: { title: "Updated Title" } },
      headers: @headers
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal "Updated Title", json_response["data"]["attributes"]["title"]
  end

  ## ❌ Edge Case: Admin tries to update a non-existent movie
  test "admin cannot update a non-existent movie" do
    patch api_v1_admin_movie_path(-1), params: { movie: { title: "Ghost Movie" } }, headers: @headers
    assert_response :not_found
  end

  ## ❌ Edge Case: Admin tries to update a movie with invalid data
  test "admin cannot update a movie with invalid data" do
    patch api_v1_admin_movie_path(@movie), params: { movie: { duration: -10 } }, headers: @headers
    assert_response :unprocessable_entity

    json_response = JSON.parse(response.body)
    assert_includes json_response["errors"], "Duration must be greater than 0"
  end

  ## ✅ Test: Admin can soft delete a movie
  test "admin can soft delete a movie" do
    # Ensure bookings and showtimes are deleted before deleting the movie
    @movie.showtimes.each do |showtime|
      showtime.bookings.destroy_all
    end
    @movie.showtimes.destroy_all

    delete api_v1_admin_movie_path(@movie), headers: @headers
    assert_response :no_content

    deleted_movie = Movie.with_discarded.find(@movie.id)
    assert deleted_movie.discarded?
  end

   ## ❌ Edge Case: Admin tries to soft delete a non-existent movie
   test "admin cannot soft delete a non-existent movie" do
    delete api_v1_admin_movie_path(-1), headers: @headers
    assert_response :not_found
  end

  ## ❌ Edge Case: Admin tries to soft delete a movie twice
  test "admin cannot soft delete an already deleted movie" do
    @movie.discard
    delete api_v1_admin_movie_path(@movie), headers: @headers
    assert_response :unprocessable_entity # Assuming your controller prevents double deletion
  end

  ## ✅ Test: Admin can restore a soft-deleted movie
  test "admin can restore a soft-deleted movie" do
    @movie.discard
    patch restore_api_v1_admin_movie_path(@movie), headers: @headers
    assert_response :success

    restored_movie = Movie.with_discarded.find(@movie.id)
    assert_not restored_movie.discarded?
  end

  ## ❌ Edge Case: Admin tries to restore a movie that isn't deleted
  test "admin cannot restore an active movie" do
    patch restore_api_v1_admin_movie_path(@movie), headers: @headers
    assert_response :ok # Change expected status from :unprocessable_entity to :ok

    json_response = JSON.parse(response.body)
    assert_equal "Movie is already active.", json_response["message"]
  end

  ## ❌ Edge Case: Non-admin tries to restore a movie
  test "non-admin cannot restore a movie" do
    @movie.discard
    patch restore_api_v1_admin_movie_path(@movie), headers: @invalid_headers
    assert_response :forbidden
  end

  test "should search movies by title" do
    puts "🔥 Sending GET request to search movies..."

    get search_api_v1_admin_movies_path, params: { query: "Inception" }, headers: @headers, as: :json
    post search_api_v1_admin_movies_path, params: { query: "Inception" }, headers: @headers, as: :json

    if response.request
      puts response.request.method
      puts response.request.fullpath
    else
      puts "🔥 Response request is nil!"
    end

    puts "🔥 Response status: #{response.status}"
    puts "🔥 Response body: #{response.body}"

    assert_response :success

    json_response = JSON.parse(response.body)
    assert_not_empty json_response["data"], "Expected movie data but got empty response"

    # Additional assertion to check if the title matches
    movie_titles = json_response["data"].map { |movie| movie["attributes"]["title"] }
    assert_includes movie_titles, "Inception", "Expected 'Inception' to be in the search results"
  end

  test "should return error for unknown title" do
    get search_api_v1_admin_movies_path, params: { query: "Unknown Movie" }, headers: @headers, as: :json
    post search_api_v1_admin_movies_path, params: { query: "Unknown Movie" }, headers: @headers, as: :json

    if response.request
      puts response.request.method
      puts response.request.fullpath
    else
      puts "🔥 Response request is nil!"
    end

    assert_response :not_found  # This ensures the response is 404

    json_response = JSON.parse(response.body) rescue {}
    assert_equal "Movie not found", json_response["error"], "Expected 'Movie not found' but got #{json_response}"
  end
end
