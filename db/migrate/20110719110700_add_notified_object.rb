class AddNotifiedObject < ActiveRecord::Migration
  def self.up
    change_table :notifications do |t|
      t.references :notified_object, :polymorphic => true
    end
  end

  def self.down
    change_table :notifications do |t|
      t.remove :notified_object
    end
  end
end
