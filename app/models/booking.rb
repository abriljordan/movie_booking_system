class Booking < ApplicationRecord
  include Discard::Model # This makes the model discardable

  before_validation :calculate_total_price, if: -> { total_price.blank? }


  belongs_to :user
  belongs_to :showtime

  validates :seats, :total_price, presence: true

  validates :seats, numericality: { greater_than: 0 }


  def calculate_total_price
    self.total_price = seats * showtime.price if showtime.present?
  end
end
