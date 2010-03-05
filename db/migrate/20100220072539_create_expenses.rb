class CreateExpenses < ActiveRecord::Migration
  def self.up
    create_table :expenses do |t|
      t.string :description
      t.float :amount
      t.datetime :exp_date
      t.integer :category_id, :options => "CONSTRAINTS fk_categoryid REFERENCES category(id)"
      t.integer :user_id, :options => "CONSTRAINTS fk_userid REFERENCES users(id)"

      t.timestamps
    end
  end

  def self.down
    drop_table :expenses
  end
end
