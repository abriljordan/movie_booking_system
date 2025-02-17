class RenameDeletedAtToDiscardedAt < ActiveRecord::Migration[8.0]
  def change
    rename_column :users, :deleted_at, :discarded_at
    rename_column :theaters, :deleted_at, :discarded_at
    rename_column :showtimes, :deleted_at, :discarded_at
  end
end
