class ManagerController < ActionController::Base
  def public_set_owner 
    set_owner 
  end

  def public_reset_owner
    reset_owner
  end        

  def public_get_current_owner 
    get_current_owner 
  end
  
  # Re-raise errors caught by the controller.
  def rescue_action(e) raise e end;

  private
  
  def current_person
    Person.find(92634)
  end
  
  def current_user
    User.find(15464)
  end
end