require "test_helper"

class Api::V1::Admin::TheatersControllerTest < ActionDispatch::IntegrationTest
  setup do
    #  @user = users(:user_two) # Ensure this fixture exists
    @admin = users(:user_one) # Ensure an admin fixture exists

    @theater = theaters(:theater_one) # Assuming you have a theater fixture
    @headers = { "Authorization" => "Bearer #{JsonWebToken.encode(user_id: @admin.id, role: 'admin')}" }
  end

  test "admin can create theater" do
    assert_difference("Theater.count", 1) do
      post api_v1_admin_theaters_path,
        params: { theater: { name: "New Theater", location: "Downtown", total_seats: 200 } },
        headers: @headers
    end
    assert_response :created
  end

  test "admin can update theater" do
    patch api_v1_admin_theater_path(@theater),
      params: { theater: { name: "Updated Theater" } },
      headers: @headers

    assert_response :success
    assert_equal "Updated Theater", @theater.reload.name
  end

  test "admin can soft delete theater" do
    delete api_v1_admin_theater_path(@theater), headers: @headers
    assert_response :ok
    assert_not_nil @theater.reload.discarded_at
  end


  test "non-admin can be forbidden from creating a theater" do
    user = users(:user_two) # Non-admin user
    headers = { "Authorization" => "Bearer #{JsonWebToken.encode(user_id: user.id, role: 'customer')}" }

    post api_v1_admin_theaters_path,
      params: { theater: { name: "Unauthorized Theater" } },
      headers: headers

    assert_response :forbidden
  end
end
