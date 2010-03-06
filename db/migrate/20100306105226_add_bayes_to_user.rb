class AddBayesToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :use_bayes, :integer
  end

  def self.down
    remove_column :users, :use_bayes
  end
end
