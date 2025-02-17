class Theater < ApplicationRecord
  include Discard::Model

  has_many :showtimes, dependent: :destroy
  validates :name, :location, presence: true
  validates :total_seats, presence: true, numericality: { only_integer: true, greater_than: 0 }

  self.discard_column = :discarded_at
  default_scope -> { kept }
end
