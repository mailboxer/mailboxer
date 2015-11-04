# This migration comes from mailboxer_engine (originally 20131206080417)
class AddMissingIndices < ActiveRecord::Migration
  def change
    # We'll explicitly specify its name, as the auto-generated name is too long and exceeds 63
    # characters limitation.
    add_index :mailboxer_conversation_opt_outs, [:unsubscriber_id, :unsubscriber_type],
      name: 'index_mailboxer_conversation_opt_outs_on_unsubscriber_id_type'
    add_index :mailboxer_conversation_opt_outs, :conversation_id

    add_index :mailboxer_notifications, :type
    add_index :mailboxer_notifications, [:sender_id, :sender_type]

    # We'll explicitly specify its name, as the auto-generated name is too long and exceeds 63
    # characters limitation.
    add_index :mailboxer_notifications, [:notified_object_id, :notified_object_type],
      name: 'index_mailboxer_notifications_on_notified_object_id_and_type'

    add_index :mailboxer_receipts, [:receiver_id, :receiver_type]
  end
end
