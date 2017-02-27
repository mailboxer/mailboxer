class MailboxerNamespacingCompatibility < ActiveRecord::Migration

  def self.up
    rename_table :conversations, :mailboxer_conversations
    rename_table :notifications, :mailboxer_notifications
    rename_table :receipts,      :mailboxer_receipts

    Mailboxer::Notification.where(type: 'Message').update_all(type: 'Mailboxer::Message')
  end

  def self.down
    rename_table :mailboxer_conversations, :conversations
    rename_table :mailboxer_notifications, :notifications
    rename_table :mailboxer_receipts,      :receipts

    Mailboxer::Notification.table_name = "notifications"
    Mailboxer::Notification.where(type: 'Mailboxer::Message').update_all(type: 'Message')
  end
end
