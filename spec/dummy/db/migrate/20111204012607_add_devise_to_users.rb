class AddDeviseToUsers < ActiveRecord::Migration
  def up
    add_column :users, :encrypted_password, :string
  end

  def down
    remove_column :users, :encrypted_password, :string
  end
end
