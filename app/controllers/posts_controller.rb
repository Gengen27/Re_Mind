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
      # AI評価を自動実行（オプション）
      if params[:auto_evaluate] == '1' && @post.needs_ai_evaluation?
        @post.request_ai_evaluation
      end
      
      redirect_to @post, notice: '失敗ログを投稿しました。'
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
