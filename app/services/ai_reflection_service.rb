require 'openai'

class AiReflectionService
  attr_reader :user, :start_date, :end_date

  def initialize(user, start_date: 1.month.ago, end_date: Time.current)
    @user = user
    @start_date = start_date
    @end_date = end_date
    @client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])
  end

  def generate_reflection
    return nil unless can_generate?

    begin
      response = request_reflection
      # 全てのデータを返す（summary, growth_points, improvement_areas, future_advice）
      response
    rescue StandardError => e
      Rails.logger.error "AI Reflection Error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      nil
    end
  end

  private

  def can_generate?
    return false unless ENV['OPENAI_API_KEY'].present?
    return false unless posts.any?
    
    # AI評価済みの投稿が存在することを確認
    posts_with_scores = posts.select { |p| p.ai_score.present? }
    return false unless posts_with_scores.any?
    
    true
  end

  def posts
    @posts ||= user.posts
                   .includes(:ai_score, :category)
                   .where(created_at: start_date..end_date)
                   .where(ai_evaluated: true)
                   .order(created_at: :asc)
  end

  def request_reflection
    prompt = build_reflection_prompt
    
    response = @client.chat(
      parameters: {
        model: 'gpt-4-turbo-preview',
        messages: [
          { role: 'system', content: system_message },
          { role: 'user', content: prompt }
        ],
        temperature: 0.8,
        response_format: { type: 'json_object' }
      }
    )

    content = response.dig('choices', 0, 'message', 'content')
    
    if content.blank?
      Rails.logger.error "AI Reflection: Empty response from API"
      raise StandardError, "AI API returned empty response"
    end
    
    parsed_response = JSON.parse(content)
    
    # 必要なキーが存在することを確認
    unless parsed_response.is_a?(Hash) && parsed_response['summary'].present?
      Rails.logger.error "AI Reflection: Invalid response format: #{parsed_response.inspect}"
      raise StandardError, "AI API returned invalid response format"
    end
    
    parsed_response
  rescue JSON::ParserError => e
    Rails.logger.error "AI Reflection JSON Parse Error: #{e.message}"
    Rails.logger.error "Response content: #{content.inspect}"
    raise StandardError, "Failed to parse AI response: #{e.message}"
  end

  def system_message
    <<~MSG
      あなたは成長支援AIメンターです。
      ユーザーの一定期間の失敗ログを分析し、成長の軌跡と今後の課題を総評してください。
      
      以下の観点で分析してください：
      1. スコアの推移と傾向
      2. よく現れる失敗パターン
      3. 成長が見られる点
      4. 今後意識すべきポイント
      
      必ずJSON形式で以下の情報を返してください：
      {
        "summary": "<500文字程度の総評>",
        "growth_points": ["<成長ポイント1>", "<成長ポイント2>", ...],
        "improvement_areas": ["<改善点1>", "<改善点2>", ...],
        "future_advice": "<今後のアドバイス>"
      }
    MSG
  end

  def build_reflection_prompt
    posts_summary = posts.map.with_index(1) do |post, index|
      score = post.ai_score
      # ai_scoreが存在することを確認（既にwhere(ai_evaluated: true)でフィルタ済みだが、念のため）
      next nil unless score
      next nil unless post.category
      
      <<~POST
        【投稿#{index}】#{post.created_at.strftime('%Y/%m/%d')}
        カテゴリ: #{post.category.name}
        タイトル: #{post.title}
        スコア: #{score.total_score}点 (原因分析: #{score.cause_analysis_score || 'N/A'}, 対策: #{score.solution_specificity_score || 'N/A'}, 学び: #{score.learning_articulation_score || 'N/A'}, 再発防止: #{score.prevention_awareness_score || 'N/A'})
        AI評価: #{score.feedback_comment || '評価なし'}
        
      POST
    end.compact.join("\n")

    # 平均スコアの計算（ai_scoreが存在する投稿のみ）
    scored_posts = posts.select { |p| p.ai_score.present? }
    average_score = if scored_posts.any?
      scored_posts.sum { |p| p.ai_score.total_score }.to_f / scored_posts.count
    else
      0.0
    end
    
    # posts_summaryが空の場合はエラー
    if posts_summary.blank?
      Rails.logger.error "AI Reflection: No valid posts found with AI scores"
      raise StandardError, "有効な投稿が見つかりませんでした"
    end
    
    <<~PROMPT
      期間: #{start_date.strftime('%Y/%m/%d')} 〜 #{end_date.strftime('%Y/%m/%d')}
      投稿数: #{posts.count}件
      平均スコア: #{average_score.round(1)}点
      
      #{posts_summary}
      
      上記の失敗ログから、ユーザーの成長の軌跡を分析し、建設的な総評を提供してください。
    PROMPT
  end
end
