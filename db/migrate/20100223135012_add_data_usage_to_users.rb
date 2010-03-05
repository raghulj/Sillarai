class AddDataUsageToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :data_usage, :integer
  end

  def self.down
    remove_column :users, :data_usage
  end
end
