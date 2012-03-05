class AddNotifiedObject < ActiveRecord::Migration
  def self.up
    change_table :notifications do |t|
      t.references :notified_object, :polymorphic => true
      t.remove :object_id
      t.remove :object_type
    end
  end

  def self.down
    change_table :notifications do |t|
      t.remove :notified_object_id
      t.remove :notified_object_type
      t.references :object, :polymorphic => true
    end
  end
end
