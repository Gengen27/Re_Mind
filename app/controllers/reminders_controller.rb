class RemindersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_reminder, only: [:show, :update, :complete, :skip]

  def index
    @reminders = current_user.reminders
                             .includes(post: :category)
                             .order(scheduled_date: :desc)
                             .page(params[:page]).per(20)
    
    @pending_count = current_user.reminders.where(status: ['ready', 'in_progress']).count
    @completed_count = current_user.reminders.where(status: 'completed').count
  end

  def show
    @reflection_items = @reminder.reflection_items.ordered
    @post = @reminder.post
    
    # 初回アクセス時にin_progressに変更
    if @reminder.status == 'ready'
      @reminder.mark_as_in_progress!
    end
  end

  def update
    # チェック項目の更新は reflection_items_controller で処理
    redirect_to @reminder
  end

  def complete
    if @reminder.all_items_checked?
      # 全項目完了
      @reminder.mark_as_completed!
      redirect_to reminders_path, notice: '🎉 素晴らしい！振り返りが完了しました。'
    else
      # 未完了項目がある
      @reminder.update!(status: 'in_progress')
      redirect_to complete_with_incomplete_reminder_path(@reminder)
    end
  end

  def skip
    # スキップ処理（将来的な拡張用）
    @reminder.update!(status: 'completed', completed_at: Time.current)
    redirect_to reminders_path, notice: 'この振り返りをスキップしました。'
  end

  private

  def set_reminder
    @reminder = current_user.reminders.find(params[:id])
  end
end

