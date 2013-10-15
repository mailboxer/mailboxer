class MailboxerNamespacingCompatibility < ActiveRecord::Migration

  def self.up
    rename_table :conversations, :mailboxer_conversations
    rename_table :notifications, :mailboxer_notifications
    rename_table :receipts,      :mailboxer_receipts

    if Rails.version < '4'
      rename_index :mailboxer_notifications, :notifications_on_conversation_id, :mailboxer_notifications_on_conversation_id
      rename_index :mailboxer_receipts,      :receipts_on_notification_id,      :mailboxer_receipts_on_notification_id
    end
  end

  def self.down
    rename_table :mailboxer_conversations, :conversations
    rename_table :mailboxer_notifications, :notifications
    rename_table :mailboxer_receipts,      :receipts

    if Rails.version < '4'
      rename_index :notifications, :mailboxer_notifications_on_conversation_id, :notifications_on_conversation_id
      rename_index :receipts,      :mailboxer_receipts_on_notification_id,      :receipts_on_notification_id
    end
  end
end
