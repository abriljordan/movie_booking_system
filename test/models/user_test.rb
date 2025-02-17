# test/models/user_test.rb
require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = users(:user_one)
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "name should be present" do
    @user.name = ""
    assert_not @user.valid?
  end

  test "email should be present" do
    @user.email = ""
    assert_not @user.valid?
  end

  test "email should be unique" do
    duplicate_user = @user.dup
    assert_not duplicate_user.valid?
  end
end
