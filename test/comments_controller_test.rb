$:.unshift(File.dirname(__FILE__))

require 'helpers/test_helper'
require 'models/person'
require 'models/comment'
require 'controllers/comments_controller'

ActionController::Routing::Routes.draw do |map|
  map.connect  ':controller/:action/:id'
end

class CommentsControllerTest < Test::Unit::TestCase
  fixtures :people, :comments

  module ::ActionController
    class Base
      private
      def current_person; Person.find(92634); end        
    end
  end
  
  def setup
    @controller = CommentsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_create_comment
    post :create, :comment => {:comment => 'New-ONE'}
    assert_response :success
    assert_equal    'New-ONE', assigns["comment"].comment
    assert_equal     people(:test), assigns["comment"].person
  end
  
  def test_update_comment_preserve_owner
    post :update, :id => 3000, :comment => {:comment => 'Different'}
    assert_response :success
    assert_equal    'Different', assigns["comment"].comment
    assert_equal     people(:chris), assigns["comment"].person
  end
end
