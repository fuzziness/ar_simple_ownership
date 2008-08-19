class Book < ActiveRecord::Base
  ownable
  has_many :comments
  
  named_scope :with_title, lambda { |*args| {:conditions => {:title => args.first}} }
end