class User < ApplicationRecord
  include Discard::Model

  has_secure_password
  has_many :bookings

  enum :role, { customer: 0, admin: 1 } # Rails 8


  self.discard_column = :discarded_at # Explicitly use discarded_at
  default_scope -> { kept }

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, on: :create


  def admin?
    role == "admin"
  end
end
