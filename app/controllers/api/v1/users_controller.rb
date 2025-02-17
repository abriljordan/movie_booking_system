# app/controllers/api/v1/users_controller.rb
class Api::V1::UsersController < ApplicationController
  before_action :authenticate_user!, except: [ :create ]
  before_action :authenticate_admin!, only: [ :destroy ]
  before_action :set_user, only: [ :show, :update, :destroy ]
  before_action :authorize_user!, only: [ :update ]

  def show
    return head :not_found unless @user
    render json: UserSerializer.new(@user)
  end

  def create
    @user = User.new(user_params)
    if @user.save
      render json: UserSerializer.new(@user), status: :created
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @user.update(user_params)
      render json: UserSerializer.new(@user)
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    return render json: { error: "User not found" }, status: :not_found unless @user

    if @user.discard
      render json: { message: "User has been soft deleted" }, status: :ok
    else
      render json: { error: @user.errors.full_messages.to_sentence }, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = params[:id] == "me" ? current_user : User.find_by(id: params[:id])
  end

  def authorize_user!
    render json: { error: "Unauthorized" }, status: :unauthorized unless current_user == @user
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
