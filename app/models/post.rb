class Post < ApplicationRecord
  belongs_to :user
  belongs_to :category
  has_one :ai_score, dependent: :destroy
  
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
end