class AddDiscardedAtToBookings < ActiveRecord::Migration[8.0]
  def change
    add_column :bookings, :discarded_at, :datetime
  end
end
