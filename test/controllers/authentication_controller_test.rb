require "test_helper"

class AuthenticationTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:user_one)
    @admin = users(:user_two)
    @valid_token = JsonWebToken.encode(user_id: @user.id)
    @invalid_token = "invalid_token"
  end

  test "should get user from Authorization token" do
    get api_v1_user_path(@user.id), headers: { "Authorization" => "Bearer #{@valid_token}" }, as: :json
    assert_response :success
    assert_equal @user.id, JSON.parse(@response.body)["data"]["id"].to_i
  end

  test "should not get user from empty Authorization token" do
    get api_v1_user_path(@user), headers: {}, as: :json
    assert_response :unauthorized
    json_response = response.body.present? ? JSON.parse(response.body, symbolize_names: true) : {}
    assert_equal "Unauthorized: Token missing", json_response[:error], "Expected error message to match"
  end

  test "should not get user from invalid Authorization token" do
    get api_v1_user_path(@user), headers: { "Authorization" => "Bearer #{@invalid_token}" }, as: :json
    assert_response :unauthorized
    json_response = response.body.present? ? JSON.parse(response.body, symbolize_names: true) : {}
    assert_equal "Unauthorized: Invalid token payload", json_response[:error], "Expected error message to match"
  end
end
