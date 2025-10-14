class CategoriesController < ApplicationController
  before_action :authenticate_user!

  def index
    @categories = Category.all
    @category_stats = @categories.map do |category|
      posts = current_user.posts.where(category: category)
      {
        category: category,
        posts_count: posts.count,
        average_score: posts.joins(:ai_score).average('ai_scores.total_score')&.round(1)
      }
    end
  end

  def show
    @category = Category.find(params[:id])
    @posts = current_user.posts.where(category: @category)
                        .includes(:ai_score)
                        .recent
                        .page(params[:page]).per(10)
    @average_score = @posts.joins(:ai_score).average('ai_scores.total_score')&.round(1)
  end
end
