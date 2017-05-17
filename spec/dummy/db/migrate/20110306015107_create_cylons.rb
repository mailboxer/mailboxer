class CreateCylons < ActiveRecord::Migration[4.2]
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
