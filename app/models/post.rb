class Post < ApplicationRecord
  belongs_to :user
  belongs_to :category
  has_one :ai_score, dependent: :destroy
  has_many :reminders, dependent: :destroy
  has_many :reflection_items, dependent: :destroy
  
  validates :title, presence: true, length: { maximum: 200 }
  validates :content, presence: true, length: { maximum: 5000 }
  validates :cause, length: { maximum: 2000 }
  validates :solution, length: { maximum: 2000 }
  validates :learning, length: { maximum: 2000 }

  scope :recent, -> { order(created_at: :desc) }
  scope :by_category, ->(category_id) { where(category_id: category_id) if category_id.present? }
  scope :with_ai_score, -> { where(ai_evaluated: true).joins(:ai_score) }
  scope :search_by_keyword, ->(keyword) { 
    where("title LIKE ? OR content LIKE ? OR cause LIKE ? OR solution LIKE ? OR learning LIKE ?", 
          "%#{keyword}%", "%#{keyword}%", "%#{keyword}%", "%#{keyword}%", "%#{keyword}%") if keyword.present?
  }
  # AIスコアを取得（存在しない場合はnilを返す）
  def score
    ai_score&.total_score
  end
  
  # AI評価が必要かどうか
  def needs_ai_evaluation?
    !ai_evaluated && cause.present? && solution.present?
  end

  # AI評価を実行
  def request_ai_evaluation
    return false if ai_evaluated
    
    ::AiEvaluationService.new(self).evaluate
  end
  
  # リマインドを作成
  def create_reminders!
    return if reminders.any? # 既に作成済みの場合はスキップ
    
    reminder_types = %w[day_1 day_3 day_7 day_30 day_90]
    days_map = { 'day_1' => 1, 'day_3' => 3, 'day_7' => 7, 'day_30' => 30, 'day_90' => 90 }
    
    reminder_types.each do |type|
      reminders.create!(
        user: user,
        reminder_type: type,
        scheduled_date: created_at.to_date + days_map[type].days,
        status: 'pending'
      )
    end
  end
  
  # 振り返り準備が完了しているか
  def reflection_ready?
    reminders.any? && reminders.all? { |r| r.total_items_count > 0 }
  end
end