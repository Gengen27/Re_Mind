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
end
