class AiScore < ApplicationRecord
  belongs_to :post
  
  validates :total_score, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :cause_analysis_score, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 25 }, allow_nil: true
  validates :solution_specificity_score, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 25 }, allow_nil: true
  validates :learning_articulation_score, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 25 }, allow_nil: true
  validates :prevention_awareness_score, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 25 }, allow_nil: true

  RANK_DATA = {
    'S' => { range: 90..100, color: '#FFD700', message: '素晴らしい内省です！' },
    'A' => { range: 80..89,  color: '#10B981', message: '非常に良い分析ができています' },
    'B' => { range: 70..79,  color: '#3B82F6', message: '良い振り返りです' },
    'C' => { range: 60..69,  color: '#F59E0B', message: 'もう少し深掘りできそうです' },
    'D' => { range: 50..59,  color: '#EF4444', message: '改善の余地があります' },
    'E' => { range: 0..49,   color: '#6B7280', message: 'より具体的に記述しましょう' }
  }.freeze

  # スコアのランクを返す
  def rank
    @rank ||= RANK_DATA.find { |_rank, data| data[:range].include?(total_score) }&.first
  end
  
  # ランクの色を返す
  def rank_color
    RANK_DATA[rank][:color] if rank
  end
  
  # スコアの評価コメント
  def evaluation_message
    RANK_DATA[rank][:message] if rank
  end
end