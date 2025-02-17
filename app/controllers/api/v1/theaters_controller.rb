
class Api::V1::TheatersController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index, :show ]

  def index
    @theaters = Theater.kept
    render json: TheaterSerializer.new(@theaters)
  end

  def show
    @theater = Theater.find(params[:id])
    render json: TheaterSerializer.new(@theater)
  end
end
