class ApplicationController < ActionController::Base
  # 本番環境でのみベーシック認証を有効化
  before_action :basic_auth, if: :production?
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
  
  private
  
  def production?
    Rails.env.production?
  end
  
  def basic_auth
    authenticate_or_request_with_http_basic do |username, password|
      username == ENV['BASIC_AUTH_USER'] && password == ENV['BASIC_AUTH_PASSWORD']
    end
  end
end
