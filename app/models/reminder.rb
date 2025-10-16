class Reminder < ApplicationRecord
  belongs_to :post
  belongs_to :user
  has_many :reflection_items, dependent: :destroy
  
  # バリデーション
  validates :reminder_type, presence: true, 
            inclusion: { in: %w[day_1 day_3 day_7 day_30 day_90] }
  validates :scheduled_date, presence: true
  validates :status, presence: true,
            inclusion: { in: %w[pending ready in_progress completed] }
  validates :checked_items_count, numericality: { greater_than_or_equal_to: 0 }
  validates :total_items_count, numericality: { greater_than_or_equal_to: 0 }
  validates :retry_count, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 3 }
  
  # スコープ
  scope :pending, -> { where(status: 'pending') }
  scope :ready, -> { where(status: 'ready') }
  scope :in_progress, -> { where(status: 'in_progress') }
  scope :completed, -> { where(status: 'completed') }
  scope :for_user, ->(user_id) { where(user_id: user_id) }
  scope :scheduled_today_or_before, -> { where('scheduled_date <= ?', Date.current) }
  
  # リマインドタイプの日本語名
  def reminder_type_name
    case reminder_type
    when 'day_1'
      '1日後'
    when 'day_3'
      '3日後'
    when 'day_7'
      '7日後'
    when 'day_30'
      '30日後'
    when 'day_90'
      '90日後'
    end
  end
  
  # リマインドタイプの日数を取得
  def days_after
    case reminder_type
    when 'day_1' then 1
    when 'day_3' then 3
    when 'day_7' then 7
    when 'day_30' then 30
    when 'day_90' then 90
    end
  end
  
  # 完了率を計算
  def completion_rate
    return 0 if total_items_count.zero?
    (checked_items_count.to_f / total_items_count * 100).round
  end
  
  # 全項目完了しているか
  def all_items_checked?
    total_items_count.positive? && checked_items_count == total_items_count
  end
  
  # 未完了項目があるか
  def has_unchecked_items?
    checked_items_count < total_items_count
  end
  
  # 未完了項目を取得
  def unchecked_items
    reflection_items.where(checked: false)
  end
  
  # チェック済み項目を取得
  def checked_items
    reflection_items.where(checked: true)
  end
  
  # AIアドバイスをパース
  def parsed_ai_advice
    return nil if ai_advice.blank?
    JSON.parse(ai_advice)
  rescue JSON::ParserError
    nil
  end
  
  # ステータスを更新
  def mark_as_ready!
    update!(status: 'ready')
  end
  
  def mark_as_in_progress!
    update!(status: 'in_progress')
  end
  
  def mark_as_completed!
    update!(status: 'completed', completed_at: Time.current)
  end
  
  # チェック数を更新
  def update_checked_count!
    update!(checked_items_count: reflection_items.where(checked: true).count)
  end
end

