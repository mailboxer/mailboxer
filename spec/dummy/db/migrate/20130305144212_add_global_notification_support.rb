class AddGlobalNotificationSupport < ActiveRecord::Migration

  def change
    change_table :mailboxer_notifications do |t|
      t.boolean :global
      t.datetime :expires
    end
    Mailboxer::Notification.update_all ["global = ?", false]
  end

end
