class AddAttachments < ActiveRecord::Migration
  def self.up
    change_table :notifications do |t|
      t.string :attachment, :default => nil
    end
  end

  def self.down
    change_table :notifications do |t|
      t.remove :attachment
    end
  end
end
