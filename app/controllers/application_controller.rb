class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_pending_reminders_count

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end
  
  def set_pending_reminders_count
    if user_signed_in?
      @pending_reminders_count = current_user.reminders
                                             .where(status: ['ready', 'in_progress'])
                                             .count
    end
  end
end
