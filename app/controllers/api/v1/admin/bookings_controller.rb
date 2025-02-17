class Api::V1::Admin::BookingsController < ApplicationController
  before_action :authenticate_admin!

  def index
    @bookings = Booking.all
    render json: @bookings
  end

  def create
    @booking = Booking.new(booking_params)
    if @booking.save
      render json: @booking, status: :created
    else
      Rails.logger.debug @booking.errors.full_messages.inspect # Debugging line
      render json: { errors: @booking.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    @booking = Booking.find_by(id: params[:id])
    return render json: { error: "Booking not found" }, status: :not_found unless @booking

    if @booking.update(booking_params)
      render json: @booking
    else
      render json: @booking.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @booking = Booking.find(params[:id])
    if @booking.discard
      render json: { message: "Booking discarded successfully" }, status: :ok
    else
      render json: { error: "Failed to discard booking" }, status: :unprocessable_entity
    end
  end

  def restore
    @booking = Booking.find(params[:id])
    @booking.undiscard # Restore soft-deleted movie
    render json: BookingSerializer.new(@booking)
  end

  private

  def set_booking
    @booking = Booking.find_by(id: params[:id])
    render json: { error: "Booking not found" }, status: :not_found unless @booking
  end

  def booking_params
    params.require(:booking).permit(:user_id, :showtime_id, :seats, :total_price, :status)
  end
end
