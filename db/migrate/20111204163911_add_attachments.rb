class AddAttachments < ActiveRecord::Migration
  def self.up
    add_column :mailboxer_notifications, :attachment, :string
  end
  
  def self.down
    remove_column :mailboxer_notifications, :attachment, :string
  end
end
