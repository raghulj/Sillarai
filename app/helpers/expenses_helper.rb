module ExpensesHelper
  def get_category_colour(color)
    unless color.category.blank?
      color.category.colour
    else
      'FFFFFF'
    end
  end
end
