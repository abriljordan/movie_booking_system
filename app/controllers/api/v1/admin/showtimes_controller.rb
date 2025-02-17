class Api::V1::Admin::ShowtimesController < ApplicationController
  before_action :set_showtime, only: %i[update destroy]

  def create
    @showtime = Showtime.new(showtime_params)
    if @showtime.save
      render json: ShowtimeSerializer.new(@showtime), status: :created
    else
      render json: { errors: showtime.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @showtime.update(showtime_params)
      render json: ShowtimeSerializer.new(@showtime)
    else
      render json: { errors: @showtime.errors.full_messages.to_sentence }, status: :unprocessable_entity
    end
  end

  def destroy
    if @showtime.discard
      render json: { message: "Showtime was successfully soft deleted." }, status: :ok
    else
      render json: { error: @showtime.errors.full_messages.to_sentence }, status: :unprocessable_entity
    end
  end

  private

  def set_showtime
    @showtime = Showtime.find_by(id: params[:id])
    render json: { error: "Showtime not found" }, status: :not_found unless @showtime
  end

  def showtime_params
    params.require(:showtime).permit(:start_time, :end_time, :movie_id, :theater_id)
  end
end
