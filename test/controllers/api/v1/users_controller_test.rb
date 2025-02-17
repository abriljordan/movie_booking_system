require "test_helper"

class Api::V1::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:user_two) # Ensure this fixture exists
    @admin = users(:user_one) # Ensure an admin fixture exists
  end

  def auth_headers(user)
    token = JsonWebToken.encode(user_id: user.id) # Ensure you have a working JWT encoder
    { "Authorization" => "Bearer #{token}" }
  end

  test "should get user when authenticated" do
    get api_v1_user_path(@user), headers: auth_headers(@user), as: :json
    assert_response :success
  end

  test "should not get user when not authenticated" do
    get api_v1_user_path(@user), as: :json
    assert_response :unauthorized
  end

  test "should update user when authenticated" do
    patch api_v1_user_path(@user), params: { user: { name: "Updated Name" } }, headers: auth_headers(@user), as: :json
    assert_response :success
    assert_equal "Updated Name", @user.reload.name
  end

  test "should not update user when not authenticated" do
    patch api_v1_user_path(@user), params: { user: { name: "Updated Name" } }, as: :json
    assert_response :unauthorized
  end

  test "admin should soft delete user" do
    delete api_v1_user_path(@user), headers: auth_headers(@admin), as: :json

    assert_response :ok
    assert @user.reload.discarded? # ✅ Use `discarded?` instead of checking discarded_at
  end

  test "regular user should not delete user" do
    delete api_v1_user_path(@user), headers: auth_headers(@user), as: :json
    assert_response :forbidden
    assert_not @user.reload.discarded?
  end

  test "should not delete user when not authenticated" do
    delete api_v1_user_path(@user), as: :json
    assert_response :unauthorized
    assert_not @user.reload.discarded?
  end
end
