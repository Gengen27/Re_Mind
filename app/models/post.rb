class Post < ApplicationRecord
  belongs_to :user
  belongs_to :category
  has_one :ai_score, dependent: :destroy
  
  validates :title, presence: true, length: { maximum: 200 }
  validates :content, presence: true, length: { maximum: 5000 }
  validates :cause, length: { maximum: 2000 }
  validates :solution, length: { maximum: 2000 }
  validates :learning, length: { maximum: 2000 }
  