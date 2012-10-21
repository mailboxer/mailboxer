class RenameReceiptsRead < ActiveRecord::Migration
  def up
    rename_column :mailboxer_receipts, :read, :is_read
  end

  def down
    rename_column :mailboxer_receipts, :is_read, :read
  end
end
