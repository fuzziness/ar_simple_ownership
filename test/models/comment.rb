class Comment < ActiveRecord::Base
  ownable :by => :person, :on => :real_person_id
  belongs_to :book
  
  named_scope :with_comment, lambda { |*args| {:conditions => {:comment => args.first}} }
end