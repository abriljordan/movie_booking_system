class Api::V1::Admin::MoviesController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_movie, only: %i[update destroy restore]

  # ✅ List Movies
  def index
    Rails.logger.info "Fetching all movies..."

    movies = Movie.all
    render json: MovieSerializer.new(movies).serializable_hash, status: :ok
  rescue StandardError => e
    Rails.logger.error "🔥 ERROR: #{e.message}"
    render json: { error: e.message }, status: :bad_request
  end

  # ✅ Search Movies
  def search
    Rails.logger.info "🔥 SEARCH ACTION CALLED - Method: #{request.method}"
    Rails.logger.info "Query Params: #{params.inspect}"
    Rails.logger.info "Searching for movies with query: #{params[:query]}"

    query = params.require(:query)

    if query.blank?
      render json: { error: "Query cannot be blank" }, status: :unprocessable_entity
      return
    end

    movies = Movie.where("title ILIKE ?", "%#{params[:query]}%")

    if movies.exists?
      render json: MovieSerializer.new(movies).serializable_hash, status: :ok
    else
      render json: { error: "Movie not found" }, status: :not_found
    end
  rescue StandardError => e
    Rails.logger.error "🔥 ERROR: #{e.message}"
    render json: { error: e.message }, status: :bad_request
  end

  # ✅ CREATE MOVIE
  def create
    @movie = Movie.new(movie_params)
    if @movie.save
      render json: MovieSerializer.new(@movie), status: :created
    #      puts @movie.errors.full_messages
    else
      render json: { errors: @movie.errors.full_messages.to_sentence }, status: :unprocessable_entity
      #      puts @movie.errors.full_messages
    end
  end

  # ✅ UPDATE MOVIE
  def update
    if @movie.update(movie_params)
      render json: MovieSerializer.new(@movie)
    else
      render json: { errors: @movie.errors.full_messages.to_sentence }, status: :unprocessable_entity
    end
  end

  # ✅ SOFT DELETE MOVIE
  def destroy
    if @movie.showtimes.exists?
      render json: { error: "Cannot delete a movie with scheduled showtimes." }, status: :unprocessable_entity
    elsif @movie.discard
      head :no_content
    else
      render json: { error: @movie.errors.full_messages.to_sentence }, status: :unprocessable_entity
    end
  end

  # ✅ RESTORE SOFT DELETED MOVIE
  def restore
    if @movie.discarded?
      if @movie.undiscard
        render json: { message: "Movie has been restored." }, status: :ok
      else
        render json: { error: @movie.errors.full_messages.to_sentence }, status: :unprocessable_entity
      end
    else
      render json: { message: "Movie is already active." }, status: :ok
    end
  end

  private

  #  1️⃣ Where Should set_movie Be Used?
  #  •	✅ update, destroy, restore → Needs set_movie (because they modify a specific movie).
  #  •	❌ index, search → Should NOT use set_movie (because they retrieve multiple movies, not a specific one).
  def set_movie
    @movie = Movie.with_discarded.find_by(id: params[:id])
    # @movie = Movie.kept.find_by(id: params[:id])
    render json: { error: "Movie not found" }, status: :not_found unless @movie
  end

  def movie_params
    params.require(:movie).permit(:title, :description, :duration, :rating, :release_date, :genre)
  end
end
