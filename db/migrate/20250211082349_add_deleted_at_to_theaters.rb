class AddDeletedAtToTheaters < ActiveRecord::Migration[8.0]
  def change
    add_column :theaters, :deleted_at, :datetime
  end
end
