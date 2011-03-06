class CreateDucks < ActiveRecord::Migration
  def self.up
    create_table :ducks do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :ducks
  end
end
