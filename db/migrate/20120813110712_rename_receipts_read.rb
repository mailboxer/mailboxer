class RenameReceiptsRead < ActiveRecord::Migration
  def up
    rename_column :receipts, :read, :is_read
  end

  def down
    rename_column :receipts, :is_read, :read
  end
end
