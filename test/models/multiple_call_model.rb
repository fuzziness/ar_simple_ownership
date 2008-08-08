class MultipleCallModel < ActiveRecord::Base
  ownable :by => :evil, :on => :zero
  ownable :by => :someone, :on => :sort_of_id
end