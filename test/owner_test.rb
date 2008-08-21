$:.unshift(File.dirname(__FILE__))

require 'helpers/test_helper'

class OwnerTests < Test::Unit::TestCase  #:nodoc:
  fixtures :users
  
  def setup
    @mike = users(:mike)
    @jacob = users(:jacob)
  end
  
  #  def test_class_methods
  #    assert User.respond_to?('owner=')
  #    assert User.respond_to?('owner')
  #    assert User.respond_to?('reset_owner')
  #  end

  def test_usage_with_object
    User.owner= @mike
    assert_equal @mike, User.owner
  end
  
  def test_reset_owner
    User.owner= @jacob
    assert_equal @jacob, User.owner
    User.reset_owner
    assert_nil User.owner
  end

end