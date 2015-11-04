class CreateFakeAttachments < ActiveRecord::Migration[4.2]
  def self.up
    create_table :fake_attachments do |t|
      t.integer :fake_attachmentable_id
      t.string :fake_attachmentable_type
      t.string :file
      t.string :filename

      t.timestamps null: false
    end
  end

  def self.down
    drop_table :fake_attachments
  end
end
