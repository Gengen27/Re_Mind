class ReflectionItem < ApplicationRecord
  belongs_to :reminder
  belongs_to :post
  
  # バリデーション
  validates :content, presence: true, length: { maximum: 500 }
  validates :item_type, inclusion: { in: %w[memory awareness growth], allow_nil: true }
  validates :position, numericality: { greater_than_or_equal_to: 0 }
  
  # スコープ
  scope :ordered, -> { order(:position) }
  scope :checked, -> { where(checked: true) }
  scope :unchecked, -> { where(checked: false) }
  scope :ai_generated, -> { where(ai_generated: true) }
  scope :user_created, -> { where(ai_generated: false) }
  
  # コールバック
  after_save :update_reminder_checked_count
  after_destroy :update_reminder_checked_count
  
  # チェック/アンチェック
  def check!
    update!(checked: true, checked_at: Time.current)
  end
  
  def uncheck!
    update!(checked: false, checked_at: nil)
  end
  
  def toggle_check!
    if checked?
      uncheck!
    else
      check!
    end
  end
  
  # アイテムタイプの日本語名
  def item_type_name
    case item_type
    when 'memory'
      '記憶・理解'
    when 'awareness'
      '意識・気づき'
    when 'growth'
      '成長実感'
    else
      '一般'
    end
  end
  
  private
  
  def update_reminder_checked_count
    reminder.update_checked_count! if reminder.present?
  end
end

