class AddNotifiedObjectRemoveObject < ActiveRecord::Migration
  def self.up
    change_table :notifications do |t|
      t.remove :object
      t.references :notified_object, :polymorphic => true
    end
  end

  def self.down
    change_table :notifications do |t|
      t.remove :notified_object
      t.references :object, :polymorphic => true
    end
  end
end
