class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable

  has_many :posts, dependent: :destroy
  
  validates :name, presence: true, length: { maximum: 50 }
  validates :mentor_personality, inclusion: { in: %w[gentle strict logical balanced] }

    # メンター人格の日本語名を返す
  def mentor_personality_name
    case mentor_personality
    when 'gentle'
      '優しい'
    when 'strict'
      '厳しい'
    when 'logical'
      '論理的'
    when 'balanced'
      'バランス型'
    end
  end

    # スコアの統計情報を取得
  def score_statistics
    scores = posts.joins(:ai_score).pluck('ai_scores.total_score')
    return nil if scores.empty?
    
    {
      average: scores.sum / scores.size,
      max: scores.max,
      min: scores.min,
      count: scores.size
    }
  end

    # カテゴリ別の平均スコアを取得
  def category_average_scores
    posts.joins(:ai_score, :category)
         .group('categories.name')
         .average('ai_scores.total_score')
  end
end
