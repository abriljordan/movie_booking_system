class CreateShowtimes < ActiveRecord::Migration[8.0]
  def change
    create_table :showtimes do |t|
      t.datetime :start_time
      t.datetime :end_time
      t.references :movie, null: false, foreign_key: true
      t.references :theater, null: false, foreign_key: true

      t.timestamps
    end
  end
end
