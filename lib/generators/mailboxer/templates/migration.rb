class CreateMailboxer < ActiveRecord::Migration
  def self.up    
  #Tables
  	#Conversations
    create_table :conversations do |t|
      t.column :subject, :string, :default => ""
      t.column :created_at, :datetime, :null => false
      t.column :updated_at, :datetime, :null => false
    end    
  	#Receipts
    create_table :receipts do |t|
      t.references :receiver, :polymorphic => true
      t.column :message_id, :integer, :null => false
      t.column :read, :boolean, :default => false
      t.column :trashed, :boolean, :default => false
      t.column :deleted, :boolean, :default => false
      t.column :mailbox_type, :string, :limit => 25
      t.column :created_at, :datetime, :null => false
      t.column :updated_at, :datetime, :null => false
    end    
  	#Messages
    create_table :messages do |t|
      t.column :body, :text
      t.column :subject, :string, :default => ""
      t.references :sender, :polymorphic => true
      t.column :conversation_id, :integer
      t.column :draft, :boolean, :default => false
      t.column :updated_at, :datetime, :null => false
      t.column :created_at, :datetime, :null => false
    end    
    
    
  #Indexes
  	#Conversations
  	#Receipts
  	add_index "receipts","message_id"
  	#Messages  
  	add_index "messages","conversation_id"
  
  #Foreign keys    
  	#Conversations
  	#Receipts
  	add_foreign_key "receipts", "messages", :name => "receipts_on_message_id"
  	#Messages  
  	add_foreign_key "messages", "conversations", :name => "messages_on_conversation_id"
  end
  
  def self.down
  #Tables  	
  	remove_foreign_key "receipts", :name => "receipts_on_message_id"
  	remove_foreign_key "messages", :name => "messages_on_conversation_id"
  	
  #Indexes
    drop_table :receipts
    drop_table :conversations
    drop_table :messages
  end
end
