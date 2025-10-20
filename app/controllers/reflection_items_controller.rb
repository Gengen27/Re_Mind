class ReflectionItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_reflection_item, only: [:update, :destroy, :toggle_check]

  def create
    @reminder = current_user.reminders.find(params[:reminder_id])
    @reflection_item = @reminder.reflection_items.build(reflection_item_params)
    @reflection_item.post = @reminder.post
    @reflection_item.ai_generated = false

    if @reflection_item.save
      @reminder.update!(total_items_count: @reminder.reflection_items.count)
      redirect_to @reminder, notice: '項目を追加しました。'
    else
      redirect_to @reminder, alert: '項目の追加に失敗しました。'
    end
  end

  def update
    if @reflection_item.update(reflection_item_params)
      redirect_to @reflection_item.reminder, notice: '項目を更新しました。'
    else
      redirect_to @reflection_item.reminder, alert: '項目の更新に失敗しました。'
    end
  end

  def destroy
    reminder = @reflection_item.reminder
    @reflection_item.destroy
    reminder.update!(total_items_count: reminder.reflection_items.count)
    redirect_to reminder, notice: '項目を削除しました。'
  end

  def toggle_check
    @reflection_item.toggle_check!
    
    respond_to do |format|
      format.html { redirect_to @reflection_item.reminder }
      format.json { 
        render json: { 
          checked: @reflection_item.checked,
          checked_count: @reflection_item.reminder.checked_items_count,
          total_count: @reflection_item.reminder.total_items_count,
          completion_rate: @reflection_item.reminder.completion_rate
        }
      }
    end
  end

  private

  def set_reflection_item
    @reflection_item = ReflectionItem.find(params[:id])
    # セキュリティチェック：自分のリマインダーの項目のみ
    unless @reflection_item.reminder.user_id == current_user.id
      redirect_to dashboard_path, alert: 'アクセス権限がありません。'
    end
  end

  def reflection_item_params
    params.require(:reflection_item).permit(:content, :position, :item_type)
  end
end

