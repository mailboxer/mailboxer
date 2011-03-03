class CreateMailboxer < ActiveRecord::Migration
  def self.up    
    create_table :mailboxer_conversations do |t|
      t.column :subject, :string, :default => ""
      t.column :created_at, :datetime, :null => false
    end    
    create_table :mailboxer_mails do |t|
      t.column :user_id, :integer, :null => false
      t.column :mailboxer_message_id, :integer, :null => false
      #t.column :mailboxer_conversation_id, :integer
      t.column :read, :boolean, :default => false
      t.column :trashed, :boolean, :default => false
      t.column :mailbox_type, :string, :limit => 25
      t.column :created_at, :datetime, :null => false
    end    
    create_table :mailboxer_messages do |t|
      t.column :body, :text
      t.column :subject, :string, :default => ""
      t.column :headers, :text
      t.column :sender_id, :integer, :null => false
      t.column :mailboxer_conversation_id, :integer
      t.column :sent, :boolean, :default => false
      t.column :created_at, :datetime, :null => false
    end    
    create_table :mailboxer_recipients, :id => false do |t|
      t.column :mailboxer_message_id, :integer, :null => false
      t.column :recipient_id, :integer, :null => false
    end    
  end
  
  def self.down
    drop_table :mailboxer_mails
    drop_table :mailboxer_conversations
    drop_table :mailboxer_recipients
    drop_table :mailboxer_messages
  end
end
