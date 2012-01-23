class AddNotificationCode < ActiveRecord::Migration
  def self.up
    change_table :notifications do |t|
      t.string :notification_code, :default => nil
    end
  end

  def self.down
    change_table :notifications do |t|
      t.remove :notification_code
    end
  end
end