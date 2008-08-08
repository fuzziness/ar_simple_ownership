class Comment < ActiveRecord::Base
  ownable :by => :person, :on => :real_person_id
  belongs_to :book
end