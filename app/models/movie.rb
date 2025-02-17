class Movie < ApplicationRecord
  GENRES = %w[
    Action Adventure Animation Comedy Crime Documentary Drama
    Fantasy Horror Musical Mystery Romance Sci-Fi Thriller Western
  ].freeze

  include Discard::Model # This makes the model discardable

  has_many :showtimes, dependent: :restrict_with_error

  validates :title, presence: true, uniqueness: true
  validates :duration, presence: true, numericality: { greater_than: 0 }
  validates :description, presence: true
  validates :release_date, presence: true
  validates :genre, inclusion: { in: Movie::GENRES }, allow_nil: true

  before_discard :check_for_associated_showtimes # Prevent soft deletion if showtimes exist



  private

  def check_for_associated_showtimes
    if showtimes.exists?
      errors.add(:base, "Cannot delete or archive movie with associated showtimes")
      throw(:abort)
    end
  end
end
