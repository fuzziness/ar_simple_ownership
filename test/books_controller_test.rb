$:.unshift(File.dirname(__FILE__))

require 'helpers/test_helper'
require 'models/user'
require 'models/book'
require 'controllers/books_controller'

ActionController::Routing::Routes.draw do |map|
  map.connect  ':controller/:action/:id'
end

# defaults options

class BooksControllerTest < Test::Unit::TestCase
  fixtures :users, :books
  
  def setup
    @controller   = BooksController.new
    @request      = ActionController::TestRequest.new
    @response     = ActionController::TestResponse.new
    User.reset_owner
  end

  def test_create_book
    post :create, :book => {:title => 'New-ONE'}
    assert_response :success
    assert_equal    'New-ONE', assigns['book'].title
    assert_equal     users(:test), assigns['book'].user
  end
  
  def test_update_book_preserve_owner
    post :update, :id => 100, :book => {:title => 'Different'}
    assert_response :success
    assert_equal    'Different', assigns['book'].title
    assert_equal     users(:jacob), assigns['book'].user
  end
end
