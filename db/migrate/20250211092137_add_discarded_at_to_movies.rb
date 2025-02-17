class AddDiscardedAtToMovies < ActiveRecord::Migration[8.0]
  def change
    add_column :movies, :discarded_at, :datetime
    add_index :movies, :discarded_at
  end
end
