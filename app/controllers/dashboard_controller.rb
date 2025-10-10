class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @recent_posts = current_user.posts.includes(:category, :ai_score).recent.limit(5)
    @total_posts = current_user.posts.count
    @evaluated_posts = current_user.posts.where(ai_evaluated: true).count
    @average_score = current_user.posts.joins(:ai_score).average('ai_scores.total_score')&.round(1)
    @categories = Category.all
  end

  def analytics
    @posts_with_scores = current_user.posts.includes(:ai_score, :category).with_ai_score.recent
    @score_stats = current_user.score_statistics
    @category_scores = current_user.category_average_scores
  end

  def reflection
    @posts = current_user.posts.includes(:ai_score, :category).recent.page(params[:page]).per(10)
    @total_score = current_user.posts.joins(:ai_score).sum('ai_scores.total_score')
  end
end