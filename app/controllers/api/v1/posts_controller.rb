module Api
  module V1
    class PostsController < ApplicationController
      before_action :authenticate_user!

      def score_data
        post = current_user.posts.includes(:ai_score).find(params[:id])
        ai_score = post.ai_score

        if ai_score
          render json: format_score(ai_score)
        else
          render json: { error: 'AI score not found' }, status: :not_found
        end
      end

      private

      def format_score(score)
        {
          total_score: score.total_score,
          cause_analysis_score: score.cause_analysis_score,
          solution_specificity_score: score.solution_specificity_score,
          learning_articulation_score: score.learning_articulation_score,
          prevention_awareness_score: score.prevention_awareness_score,
          feedback_comment: score.feedback_comment,
          rank: score.rank,
          rank_color: score.rank_color
        }
      end
    end
  end
end