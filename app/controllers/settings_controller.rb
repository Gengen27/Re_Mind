class SettingsController < ApplicationController
  before_action :authenticate_user!

  def show
  end

  def update
    if current_user.update(user_params)
      redirect_to settings_path, notice: '設定を更新しました。'
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :mentor_personality, :reminder_enabled, :reminder_interval_days)
  end
end
