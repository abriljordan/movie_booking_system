class Api::V1::MoviesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index, :show ]

  def index
    @movies = Movie.kept
    render json: MovieSerializer.new(@movies)
  end

  def show
    @movie = Movie.kept.find_by(id: params[:id])
    if @movie
      render json: MovieSerializer.new(@movie)
    else
      render json: { errors: [ "Movie not found" ] }, status: :not_found
    end
  end
end
