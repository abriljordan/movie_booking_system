class AddDeletedAtToShowtimes < ActiveRecord::Migration[8.0]
  def change
    add_column :showtimes, :deleted_at, :datetime
  end
end
