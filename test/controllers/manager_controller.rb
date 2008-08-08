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
end