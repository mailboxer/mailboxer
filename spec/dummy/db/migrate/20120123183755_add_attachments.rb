class AddAttachments < ActiveRecord::Migration
  def change
    add_column :notifications, :attachment, :string
  end
end
