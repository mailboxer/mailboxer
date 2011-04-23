class CreateCylons < ActiveRecord::Migration
  def self.up
    create_table :cylons do |t|
      t.string :name
      t.string :email

      t.timestamps
    end
  end

  def self.down
    drop_table :cylons
  end
end
