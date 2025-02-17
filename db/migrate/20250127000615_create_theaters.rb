class CreateTheaters < ActiveRecord::Migration[8.0]
  def change
    create_table :theaters do |t|
      t.string :name
      t.string :location
      t.integer :total_seats

      t.timestamps
    end
  end
end
