class Category < ActiveRecord::Base
  has_many :expenses
  belongs_to :user

  validates_presence_of :name

  def self.create_basic_category(uid)
    n = Category.new
    n.name ="Food"
    n.colour = "04BF15"
    n.user_id = uid
    n.save
    n = Category.new
    n.name = "Travel"
    n.colour = "277ADC"
    n.user_id = uid
    n.save
  end

end
