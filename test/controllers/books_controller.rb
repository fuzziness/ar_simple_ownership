class BooksController < ActionController::Base
 
  manage_ownership

  def new
    @book = Book.new
  end

  def create
    @book = Book.create!(params[:book])
    render(:inline => "<%= @book.title %>")
  end

  def edit
    @book = Book.find(params[:id])
    render(:inline => "<%= @book.title %>")
  end
  
  def update
    @book = Book.find(params[:id])
    @book.update_attributes(params[:book])
    render(:inline => "<%= @book.title %>")
  end

end