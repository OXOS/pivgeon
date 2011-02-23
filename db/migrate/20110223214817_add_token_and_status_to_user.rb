class AddTokenAndStatusToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :activation_code, :string
    add_column :users, :status, :boolean, :default => false
  end

  def self.down
    remove_column :users, :activation_code
    remove_column :users, :status
  end
end
