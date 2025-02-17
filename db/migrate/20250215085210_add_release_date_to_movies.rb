class AddReleaseDateToMovies < ActiveRecord::Migration[8.0]
  def change
    add_column :movies, :release_date, :date
  end
end
