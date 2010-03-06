class CreateBayesQueues < ActiveRecord::Migration
  def self.up
    create_table :bayes_queues do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :bayes_queues
  end
end
