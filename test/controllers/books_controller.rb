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
      
  # Re-raise errors caught by the controller.
  def rescue_action(e) raise e end;

  private 
  
  def current_user
    User.find(15464)
  end
end