class Api::V1::Admin::TheatersController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_theater, only: %i[update destroy restore]

  def create
    @theater = Theater.new(theater_params)

    if @theater.save
      render json: TheaterSerializer.new(@theater), status: :created
    else
      render json: { errors: @theater.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @theater.update(theater_params)
      render json: TheaterSerializer.new(@theater)
    else
      render json: { errors: @theater.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if @theater.discard
      render json: { message: "Theater has been soft deleted." }, status: :ok
    else
      render json: { error: @theater.errors.full_messages.to_sentence }, status: :unprocessable_entity
    end
  end

  def restore
    if @theater.undiscard
      render json: { message: "Theater has been restored" }, status: :ok
    else
      render json: { error: @theater.errors.full_messages.to_sentence }, status: :unprocessable_entity
    end
  end

  private

  def set_theater
    @theater = Theater.find_by(id: params[:id])
    render json: { error: "Theater not found" }, status: :not_found unless @theater
  end

  def theater_params
    params.require(:theater).permit(:name, :location, :total_seats)
  end
end
