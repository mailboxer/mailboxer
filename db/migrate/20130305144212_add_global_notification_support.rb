class AddGlobalNotificationSupport < ActiveRecord::Migration

  def change
    change_table :mailboxer_notifications do |t|
      t.boolean :global, default: false
      t.datetime :expires
    end
  end
end
