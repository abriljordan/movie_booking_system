require "test_helper"

class Api::V1::MoviesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @movie1 = movies(:movie_one) # From test/fixtures/movies.yml
    @movie2 = movies(:movie_two)
  end

  test "should get index" do
    get api_v1_movies_path, as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal 2, json_response["data"].size
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
end
