class AddAttachments < ActiveRecord::Migration[4.2]
  def change
    create_table :mailboxer_attachments do |t|
      t.column :file, :string
      t.column :notification_id, :integer, :null => false
    end

    add_index 'mailboxer_attachments', 'notification_id'
  end
end
