$:.unshift(File.dirname(__FILE__))

require 'helpers/test_helper'

class OwnableTests < Test::Unit::TestCase  #:nodoc:
  fixtures :users, :people, :books, :comments

  def test_add_belongs_to_default_option
    assert_equal users(:jacob), books(:first_book).user
  end
  
  def test_add_belongs_to_custom_option
    assert_equal people(:chris), comments(:third_comment).person
  end
  
  def test_owner_class_with_default_option
    assert_equal User, Book.owner_class
  end
  
  def test_owner_class_with_custom_option
    assert_equal Person, Comment.owner_class
  end
  
  def test_owner_class_name
    assert_equal :user, Book.owner_class_name
    assert_equal :user, Book.new.owner_class_name
    assert_equal :person, Comment.owner_class_name
  end
  
  def test_owner_model_attribute
    assert_equal :user_id, Book.owner_model_attribute
    assert_equal :real_person_id, Comment.owner_model_attribute
  end
  
  def test_record_ownership
    assert Book.respond_to?(:record_ownership)
    assert Comment.respond_to?(:record_ownership)
  end
  
  def test_book_creation_with_default_option
    User.owner = jacob = users(:jacob)
    book = Book.create!(:title => "Test Book Creation")
    assert_equal jacob, book.user
  end
  
  def test_comment_creation_with_custom_option
    Person.owner = kasia = people(:kasia)
    note = Comment.create!(:comment => "Test Comment Creation")
    assert_equal kasia, note.person
  end
  
  def test_book_updating_with_default_option
    User.owner = users(:mike)
    
    book = books(:first_book)
    book.title << " - Updated"
    book.save
    book.reload
    assert_equal users(:jacob), book.user
  end
  
  def test_comment_updating_with_custom_option
    Person.owner = people(:chris)
    
    note = comments(:second_comment)
    note.comment << " - Updated"
    note.save
    note.reload
    assert_equal people(:kasia), note.person
  end
  
  def test_without_ownership
    User.owner = users(:jacob)
    book = nil
    Book.without_ownership do
      book = Book.create(:title => "Without Ownership Book")
    end
    assert_not_nil book
    assert_nil book.user
  end

  def test_named_scope_with_default_option
    assert Book.scopes.has_key?(:of_current_user)
  end

  def test_named_scope_with_custom_option
    assert Comment.scopes.has_key?(:of_current_person)
  end

  def test_find_with_scope_and_default_option
    User.owner = users(:jacob)
    assert_equal [books(:first_book)], Book.of_current_user.all
  end
  
  def test_find_with_scope_and_custom_option
    Person.owner = people(:chris)
    assert_equal [comments(:third_comment)], Comment.of_current_person.all
  end
  
  def test_find_with_default_option
    User.owner = users(:mike)
    assert_equal [books(:first_book), books(:second_book)], Book.find(:all)
  end
  
  def test_find_with_custom_option
    Person.owner = people(:kasia)
    assert_equal [comments(:first_comment),comments(:second_comment),comments(:third_comment)], Comment.find(:all)
  end
  
  def test_disallow_multiple_calls
    assert_equal :evil, MultipleCallModel.owner_class_name
    assert_equal :zero, MultipleCallModel.owner_model_attribute
  end

  #  def test_multiple_scope_find_with_default_option
  #    User.owner = users(:mike)
  #    assert_equal [books(:second_book)], Book.of_current_user.with_title('Second Book').all
  #  end

  #  def test_multiple_scope_find_with_custom_option
  #    Person.owner = people(:chris)
  #    assert_equal [comments(:third_comment)], Comment.of_current_person.with_comment('Third Comment').all
  #  end
end