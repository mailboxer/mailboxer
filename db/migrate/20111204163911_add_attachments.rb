class AddAttachments < ActiveRecord::Migration
  def self.up
    add_column :notifications, :attachment, :string
  end
  
  def self.down
    remove_column :notifications, :attachment, :string
  end
end
