# This migration comes from mailboxer_engine (originally 20151103080417)
class AddDeliveryTrackingInfoToMailboxerReceipts < ActiveRecord::Migration
  def change
    add_column :mailboxer_receipts, :is_delivered, :boolean, default: false
    add_column :mailboxer_receipts, :delivery_method, :string
    add_column :mailboxer_receipts, :message_id, :string
  end
end
