class AddGlobalNotificationSupport < ActiveRecord::Migration

  def change
    add_column :notifications, :global, :boolean, :default => false
    add_column :notifications, :expires, :datetime
  end
end
