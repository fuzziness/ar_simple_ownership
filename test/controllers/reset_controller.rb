class ResetController < ActionController::Base
  prepend_before_filter :preload_comments
      
  def null_render
    #p current_person
    render :nothing => true
  end
  
  def preload_comments
    @comments = Comment.of_current_person.all
  end
    
  # Re-raise errors caught by the controller.
  def rescue_action(e) raise e end;
  
  private
  
  def current_person
    Person.find(10) 
  end
end