class CreateCategories < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
      t.string :name
      t.string :colour
      t.integer :user_id, :options => "CONSTRAINTS fk_userid REFERENCES users(id)"
      t.timestamps
    end
  end

  def self.down
    drop_table :categories
  end
end
