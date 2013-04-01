class AddNotificationDeletedSupport < ActiveRecord::Migration

  def change
    change_table :notifications do |t|
      t.boolean :deleted, :default => false
    end
  end

end
