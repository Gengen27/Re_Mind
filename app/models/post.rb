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
  