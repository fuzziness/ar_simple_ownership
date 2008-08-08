$:.unshift(File.dirname(__FILE__))

require 'helpers/test_helper'
require 'models/user'
require 'models/person'
require 'models/book'
require 'models/camelized_model'
require 'controllers/manager_controller'

class ManagerTests < Test::Unit::TestCase #:nodoc:
  fixtures :users, :people

  module ::ActionController
    class Base
      private
      def current_person; Person.find(92634); end        
      def current_user; User.find(15464); end        
    end
  end

  def setup
    # ManagerController.reload!
    load( "controllers/manager_controller.rb")
    @controller = ManagerController.new
    @controller.owner_class= nil
#    User.owner=nil
#    Person.owner= nil
  end
  
  def test_class_methods
    assert ManagerController.respond_to?('manage_ownership')
  end
  
  def test_manage_ownership_with_default_option
    assert_nil @controller.owner_class
    ManagerController.send 'manage_ownership'
    assert_equal User, @controller.owner_class
  end
  
  def test_manage_ownership_with_symbol_camelcase
    assert_nil @controller.owner_class
    ManagerController.send 'manage_ownership', :for => :camelized_model
    assert_equal CamelizedModel, @controller.owner_class
  end
  
  def test_manage_ownership_with_string_camelcase
    assert_nil @controller.owner_class
    ManagerController.send 'manage_ownership', :for => 'camelized_model'
    assert_equal CamelizedModel, @controller.owner_class  
  end
  
  def test_manage_ownership_with_symbol
    assert_nil @controller.owner_class
    ManagerController.send 'manage_ownership', :for => :person
    assert_equal Person, @controller.owner_class
  end
  
  def test_manage_ownership_with_string
    assert_nil @controller.owner_class
    ManagerController.send 'manage_ownership', :for => 'Person'
    assert_equal Person, @controller.owner_class
  end
  
  def test_manage_ownership_with_constant
    assert_nil @controller.owner_class
    ManagerController.send 'manage_ownership', :for => Person
    assert_equal Person, @controller.owner_class
  end
  
  def test_manage_ownership_fail_with_non_owner_class
    assert_nil @controller.owner_class
    ex = assert_raise(ArgumentError) {
      ManagerController.send 'manage_ownership', :for => :integer
    }
    assert_equal("manage_ownership can't handle class Integer: did you included owner?", ex.message)
  end
  
  def test_set_owner
    Person.owner= nil
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

  # FIXME check why disallow multiple calls fails
  # def test_disallow_multiple_calls
  #  ManagerController.send 'manage_ownership', :for => 'camelized_model'
  #  ManagerController.send 'manage_ownership', :for => :person
  #  assert_equal CamelizedModel, @controller.owner_class  
  # end  
end