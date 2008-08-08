class User < ActiveRecord::Base
  acts_as_owner
end