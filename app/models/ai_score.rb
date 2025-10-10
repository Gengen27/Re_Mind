class AiScore < ApplicationRecord
  belongs_to :post
  
  validates :total_score, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :cause_analysis_score, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 25 }, allow_nil: true
  validates :solution_specificity_score, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 25 }, allow_nil: true
  validates :learning_articulation_score, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 25 }, allow_nil: true
  validates :prevention_awareness_score, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 25 }, allow_nil: true