class ChngesForUsers < ActiveRecord::Migration
  def self.up
    remove_column :users, :activation_code
    remove_column :users, :status  
  end

  def self.down
    add_column :users, :activation_code, :string
    add_column :users, :status, :integer  
  end
end
