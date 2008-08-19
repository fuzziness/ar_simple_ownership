$:.unshift(File.dirname(__FILE__))

require 'helpers/test_helper'
require 'models/user'
require 'models/person'
require 'models/camelized_model'
require 'controllers/manager_controller'

class ManagerTests < Test::Unit::TestCase #:nodoc:
  fixtures :users, :people

  def setup
    # ManagerController.reload!
    Dependencies.explicitly_unloadable_constants = 'ManagerController'
    Dependencies.remove_unloadable_constants!
    load("controllers/manager_controller.rb")
    @controller = ManagerController.new
    Person.reset_owner
    User.reset_owner
  end
  
  def test_class_method_manage_ownership
    assert ManagerController.respond_to?('manage_ownership')
  end

  def test_class_method_owner_class
    assert !ManagerController.respond_to?('owner_class')
  end
  
  def test_manage_ownership_with_default_option
    ManagerController.send 'manage_ownership'
    assert_equal User, @controller.owner_class
  end
  
  def test_manage_ownership_with_symbol_camelcase
    ManagerController.send 'manage_ownership', :for => :camelized_model
    assert_equal CamelizedModel, @controller.owner_class
  end
  
  def test_manage_ownership_with_string_camelcase
    ManagerController.send 'manage_ownership', :for => 'camelized_model'
    assert_equal CamelizedModel, @controller.owner_class  
  end
  
  def test_manage_ownership_with_symbol
    ManagerController.send 'manage_ownership', :for => :person
    assert_equal Person, @controller.owner_class
  end
  
  def test_manage_ownership_with_string
    ManagerController.send 'manage_ownership', :for => 'Person'
    assert_equal Person, @controller.owner_class
  end
  
  def test_manage_ownership_with_constant
    ManagerController.send 'manage_ownership', :for => Person
    assert_equal Person, @controller.owner_class
  end
  
  def test_manage_ownership_fail_with_non_owner_class
    ex = assert_raise(ArgumentError) {
      ManagerController.send 'manage_ownership', :for => :integer
    }
    assert_equal("manage_ownership can't handle class Integer: did you included owner?", ex.message)
  end
  
  def test_set_owner
    Person.reset_owner
    assert_nil Person.owner
    ManagerController.send 'manage_ownership', :for => :person
    @controller.public_set_owner
    assert_equal people(:test), Person.owner
  end  
  
  def test_reset_owner
    ManagerController.send 'manage_ownership', :for => :person
    Person.owner= people(:test)
    assert_equal people(:test), Person.owner
    @controller.public_reset_owner
    assert_nil Person.owner
  end
  
  def test_get_current_owner_default_option
    ManagerController.send 'manage_ownership'
    assert_equal users(:test), @controller.public_get_current_owner
  end
  
  def test_get_current_owner_custom_option
    ManagerController.send 'manage_ownership', :for => :person
    assert_equal people(:test), @controller.public_get_current_owner
  end

  def test_disallow_multiple_calls_of_manage_ownership
    ManagerController.send 'manage_ownership', :for => 'camelized_model'
    ManagerController.send 'manage_ownership', :for => :person
    assert_equal CamelizedModel, @controller.owner_class  
  end  
end