class Showtime < ApplicationRecord
  include Discard::Model
  self.discard_column = :discarded_at # Explicitly use discarded_at
  default_scope -> { kept }

  belongs_to :movie
  belongs_to :theater
  has_many :bookings

  validates :start_time, :end_time, presence: true
end
