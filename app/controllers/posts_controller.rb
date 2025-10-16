class PostsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post, only: [:show, :edit, :update, :destroy, :request_ai_evaluation]
  before_action :set_categories, only: [:new, :edit, :create, :update]

  def index
    @posts = current_user.posts.includes(:category, :ai_score)
                        .by_category(params[:category_id])
                        .search_by_keyword(params[:keyword])
                        .recent
                        .page(params[:page]).per(10)
    @categories = Category.all
  end

  def show
  end

  def new
    @post = current_user.posts.build
  end

  def edit
  end

  def create
    @post = current_user.posts.build(post_params)

    if @post.save
      # リマインド作成
      @post.create_reminders!
      
      # AI評価を自動実行（オプション）
      if params[:auto_evaluate] == '1' && @post.needs_ai_evaluation?
        @post.request_ai_evaluation
      end
      
      # AIチェックリスト生成（cause, solution, learningがある場合）
      if @post.cause.present? && @post.solution.present? && @post.learning.present?
        AiReflectionChecklistService.new(@post).generate
        redirect_to edit_reflection_checklist_post_path(@post), notice: '投稿完了！振り返りチェックリストを確認・編集できます。'
      else
        redirect_to @post, notice: '失敗ログを投稿しました。'
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @post.update(post_params)
      redirect_to @post, notice: '失敗ログを更新しました。'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy
    redirect_to posts_url, notice: '失敗ログを削除しました。'
  end

  def request_ai_evaluation
    if @post.request_ai_evaluation
      redirect_to @post, notice: 'AI評価が完了しました。'
    else
      redirect_to @post, alert: 'AI評価に失敗しました。'
    end
  end
  
  def edit_reflection_checklist
    @reminders = @post.reminders.includes(:reflection_items).order(:scheduled_date)
  end
  
  def update_reflection_checklist
    # 既存の項目を更新・削除
    if params[:items].present?
      params[:items].each do |reminder_id, items_data|
        reminder = @post.reminders.find(reminder_id)
        
        items_data.each do |item_id, item_params|
          if item_params[:_destroy] == '1'
            reminder.reflection_items.find(item_id).destroy
          else
            item = reminder.reflection_items.find(item_id)
            item.update(
              content: item_params[:content],
              position: item_params[:position]
            )
          end
        end
      end
    end
    
    # 新しい項目を追加
    if params[:new_items].present?
      params[:new_items].each do |reminder_id, new_items_data|
        reminder = @post.reminders.find(reminder_id)
        
        new_items_data.each do |item_data|
          next if item_data[:content].blank?
          
          reminder.reflection_items.create!(
            post: @post,
            content: item_data[:content],
            position: reminder.reflection_items.count,
            ai_generated: false
          )
        end
        
        # total_items_countを更新
        reminder.update!(total_items_count: reminder.reflection_items.count)
      end
    end
    
    redirect_to @post, notice: '振り返りチェックリストを保存しました。'
  end

  def search
    @posts = current_user.posts.includes(:category, :ai_score)
                        .by_category(params[:category_id])
                        .search_by_keyword(params[:keyword])
                        .recent
                        .page(params[:page]).per(10)
    @categories = Category.all
    render :index
  end

  private

  def set_post
    @post = current_user.posts.find(params[:id])
  end

  def set_categories
    @categories = Category.all
  end

  def post_params
    params.require(:post).permit(:title, :content, :cause, :solution, :learning, :category_id, :occurred_at)
  end
end
