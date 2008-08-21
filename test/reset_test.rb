$:.unshift(File.dirname(__FILE__))

require 'helpers/test_helper'

class ResetTests < Test::Unit::TestCase #:nodoc:
  fixtures :people, :comments

  def setup
    @controller = ResetController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    Person.reset_owner
  end

  def test_correct_filter_order
    get :null_render
    assert_equal [], assigns(:comments)
    ResetController.send 'manage_ownership', :for => :person, :on => :real_person_id
    get :null_render
    assert_equal [comments(:first_comment),comments(:second_comment)], assigns(:comments)
  end
  
end