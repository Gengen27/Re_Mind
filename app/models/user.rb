class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable

  has_many :posts, dependent: :destroy
  
  validates :name, presence: true, length: { maximum: 50 }
  validates :mentor_personality, inclusion: { in: %w[gentle strict logical balanced] }
  
end
