class Category < ApplicationRecord
  has_many :posts, dependent: :destroy
  
  validates :name, presence: true, uniqueness: true, length: { maximum: 50 }
  validates :color, format: { with: /\A#[0-9A-Fa-f]{6}\z/, message: "は有効なカラーコード形式である必要があります" }
end