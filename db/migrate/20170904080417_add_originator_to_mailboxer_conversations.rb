class AddOriginatorToMailboxerConversations < ActiveRecord::Migration
  def change
    change_table :mailboxer_conversations do |t|
      t.references :originator, polymorphic: true
    end

    add_index :mailboxer_conversations,
              %i[originator_id originator_type],
              unique: false,
              name: 'index_mailboxer_conversations_on_originator'
  end
end
