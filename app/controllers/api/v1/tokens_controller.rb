class Api::V1::TokensController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :create ] # Allow login without authentication

  def create
    Rails.logger.debug "Params received: #{params.inspect}"

    user_params = params[:user] || {}  # Ensure it's never nil
    @user = User.find_by(email: user_params[:email])

    Rails.logger.debug "User found: #{@user.inspect}"

    if @user&.authenticate(user_params[:password])
      token = JsonWebToken.encode(user_id: user.id, role: @user.role)
      render json: { token: token, user: UserSerializer.new(@user).serializable_hash[:data][:attributes] }, status: :created
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
      # raise "Intentional Error" # 💥 Force an error to test the rescue block

    end
  rescue StandardError => e
    Rails.logger.error "Token generation error: #{e.message}"
    render json: { error: "Something went wrong", details: e.message }, status: :internal_server_error
  end
end
