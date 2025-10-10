class Category < ApplicationRecord
  has_many :posts, dependent: :destroy
  
  validates :name, presence: true, uniqueness: true, length: { maximum: 50 }
  validates :color, format: { with: /\A#[0-9A-Fa-f]{6}\z/, message: "は有効なカラーコード形式である必要があります" }

  DEFAULT_CATEGORIES = [
    { name: '仕事', color: '#3B82F6', description: '仕事に関する失敗' },
    { name: '勉強', color: '#10B981', description: '学習に関する失敗' },
    { name: '人間関係', color: '#F59E0B', description: '人間関係に関する失敗' },
    { name: '健康', color: '#EF4444', description: '健康に関する失敗' },
    { name: 'お金', color: '#8B5CF6', description: '金銭に関する失敗' },
    { name: 'その他', color: '#6B7280', description: 'その他の失敗' }
  ].freeze

  # デフォルトカテゴリを作成
  def self.seed_default_categories
    DEFAULT_CATEGORIES.each do |category_attrs|
      find_or_create_by(name: category_attrs[:name]) do |category|
        category.assign_attributes(category_attrs.slice(:color, :description))
      end
    end
  end
end