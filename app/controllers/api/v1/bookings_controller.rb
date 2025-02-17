class Api::V1::BookingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_booking, only: [ :show, :update, :destroy ]

  # GET /api/v1/bookings
  def index
    @bookings = current_user.bookings
    render json: @bookings
  end

  # GET /api/v1/bookings/:id
  def show
    if @booking
      render json: @booking
    else
      render json: { error: "Booking not found in DB" }, status: :not_found
    end
  end

  # POST /api/v1/bookings
  def create
    @booking = current_user.bookings.new(booking_params)
    if @booking.save
      render json: @booking, status: :created
    else
      Rails.logger.error "Booking creation failed: #{@booking.errors.full_messages}"
      render json: @booking.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/bookings/:id
  def update
    if @booking.update(booking_params)
      render json: @booking
    else
      render json: @booking.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/bookings/:id
  def destroy
    @booking.destroy
    head :no_content
  end

  private

  def set_booking
    @booking = current_user.bookings.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Booking not found" }, status: :not_found
  end

  def booking_params
    params.require(:booking).permit(:showtime_id, :seats, :total_price, :status)
  end
end
