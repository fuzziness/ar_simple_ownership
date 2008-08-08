class Book < ActiveRecord::Base
  ownable
  has_many :comments
end