class AddNotificationDeletedSupport < ActiveRecord::Migration

  def change
    change_table :notifications do |t|
      t.boolean :deleted
    end
    Notification.update_all ["deleted = ?", false]
  end

end
