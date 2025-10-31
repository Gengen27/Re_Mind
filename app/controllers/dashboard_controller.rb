class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @recent_posts = current_user.posts.includes(:category, :ai_score).recent.limit(5)
    @total_posts = current_user.posts.count
    @evaluated_posts = current_user.posts.where(ai_evaluated: true).count
    @average_score = current_user.posts.joins(:ai_score).average('ai_scores.total_score')&.round(1)
    @categories = Category.all
    
    # 振り返り待ちのリマインド取得
    @pending_reminders = current_user.reminders
                                     .includes(post: :category)
                                     .where(status: ['ready', 'in_progress'])
                                     .order(:scheduled_date)
                                     .limit(5)
  end

  def analytics
    @posts_with_scores = current_user.posts.includes(:ai_score, :category).with_ai_score.recent
    @score_stats = current_user.score_statistics
    @category_scores = current_user.category_average_scores
  end

  def reflection
    @posts = current_user.posts.includes(:ai_score, :category).recent.page(params[:page]).per(10)
    @total_score = current_user.posts.joins(:ai_score).sum('ai_scores.total_score')
    @total_posts = current_user.posts.count
  end
  
  def generate_ai_summary
    # 期間の設定（デフォルト: 1ヶ月）
    period = params[:period]&.to_i || 30
    start_date = period.days.ago
    end_date = Time.current
    
    begin
      # AI総評生成
      service = AiReflectionService.new(current_user, start_date: start_date, end_date: end_date)
      @ai_summary = service.generate_reflection
      
      if @ai_summary.present? && @ai_summary.is_a?(Hash)
        # セッションに保存（または DBに保存も可能）
        session[:ai_summary] = @ai_summary.to_json
        session[:ai_summary_period] = period
        session[:ai_summary_generated_at] = Time.current
        
        redirect_to reflection_path, notice: 'AI総評を生成しました。'
      else
        redirect_to reflection_path, alert: 'AI総評の生成に失敗しました。AI評価済みの投稿が必要です。'
      end
    rescue StandardError => e
      Rails.logger.error "AI Summary Generation Error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      redirect_to reflection_path, alert: "AI総評の生成中にエラーが発生しました: #{e.message}"
    end
  end
  
  def clear_ai_summary
    session.delete(:ai_summary)
    session.delete(:ai_summary_period)
    session.delete(:ai_summary_generated_at)
    redirect_to reflection_path, notice: 'AI総評をクリアしました。'
  end
end