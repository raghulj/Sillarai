class BayesQueue < ActiveRecord::Base
  set_table_name "bayes_queue"

  def self.uniq? user_id
     find_by_user_id(user_id).blank?
  end
end
