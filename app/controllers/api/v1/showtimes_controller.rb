class Api::V1::ShowtimesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index, :show ]

  def index
    @showtimes = Showtime.includes(:movie, :theater).kept
    render json: ShowtimeSerializer.new(@showtimes)
  end

  def show
    @showtime = Showtime.find(params[:id])
    render json: ShowtimeSerializer.new(@showtime)
  end
end
