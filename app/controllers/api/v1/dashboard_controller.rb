module Api
  module V1
    class DashboardController < ApplicationController
      before_action :authenticate_user!

      def chart_data
        posts = current_user.posts.includes(:ai_score).with_ai_score.order(created_at: :asc)
        
        data = {
          labels: posts.map { |p| p.created_at.strftime('%m/%d') },
          scores: posts.map { |p| p.ai_score.total_score },
          cause_scores: posts.map { |p| p.ai_score.cause_analysis_score },
          solution_scores: posts.map { |p| p.ai_score.solution_specificity_score },
          learning_scores: posts.map { |p| p.ai_score.learning_articulation_score },
          prevention_scores: posts.map { |p| p.ai_score.prevention_awareness_score },
          category_data: category_chart_data
        }

        render json: data
      end

      private

      def category_chart_data
        category_scores = current_user.posts.joins(:ai_score, :category)
                                      .group('categories.name', 'categories.color')
                                      .average('ai_scores.total_score')
        
        {
          labels: category_scores.keys.map(&:first),
          scores: category_scores.values.map { |v| v.round(1) },
          colors: category_scores.keys.map(&:last)
        }
      end
    end
  end
end
