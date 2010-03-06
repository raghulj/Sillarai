class AddQueueTableForCache < ActiveRecord::Migration
  def self.up
    create_table :bayes_queue do |t|
      t.column :user_id,  :integer
      t.timestamps
    end
  end

  def self.down
	drop_user :bayes_queue
  end
end
