class AddGlobalNotificationSupport < ActiveRecord::Migration

  def change
    change_table :notifications do |t|
      t.boolean :global, default: false
      t.datetime :expires
    end
  end
end
