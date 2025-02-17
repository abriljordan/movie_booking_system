class Api::V1::MoviesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index, :show ]

  def index
    @movies = Movie.kept
    render json: MovieSerializer.new(@movies)
  end

  def show
    @movie = Movie.find(params[:id])
    render json: MovieSerializer.new(@movie)
  end
end
