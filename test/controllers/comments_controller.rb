class CommentsController < ActionController::Base
 
  manage_ownership :for => Person 

  def new
    @comment = Comment.new
  end

  def create
    @comment = Comment.create!(params[:comment])
    render(:inline => "<%= @comment.comment %>")
  end
  
  def edit
    @comment = Comment.find(params[:id])
    render(:inline  => "<%= @comment.comment %>")
  end
  
  def update
    @comment = Comment.find(params[:id])
    @comment.update_attributes(params[:comment])
    render(:inline => "<%= @comment.comment %>")
  end
  
  # Re-raise errors caught by the controller.
  def rescue_action(e) raise e end;

  private

  def current_person
    Person.find(92634)
  end
    
end