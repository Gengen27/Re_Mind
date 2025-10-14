require 'openai'

class AiEvaluationService
  attr_reader :post

  def initialize(post)
    @post = post
    @client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])
  end

  def evaluate
    return false unless can_evaluate?

    begin
      response = request_evaluation
      save_ai_score(response)
      true
    rescue StandardError => e
      Rails.logger.error "AI Evaluation Error: #{e.message}"
      false
    end
  end

  private

  def can_evaluate?
    ENV['OPENAI_API_KEY'].present? && post.cause.present? && post.solution.present?
  end

  def request_evaluation
    prompt = build_prompt
    
    response = @client.chat(
      parameters: {
        model: 'gpt-4-turbo-preview',
        messages: [
          { role: 'system', content: system_message },
          { role: 'user', content: prompt }
        ],
        temperature: 0.7,
        response_format: { type: 'json_object' }
      }
    )

    content = response.dig('choices', 0, 'message', 'content')
    tokens_used = response.dig('usage', 'total_tokens')
    
    result = JSON.parse(content)
    result['tokens_used'] = tokens_used
    result
  end

  def system_message
    personality = post.user.mentor_personality
    
    base_message = <<~MSG
      あなたは失敗から学ぶことを支援するAIメンターです。
      ユーザーの失敗経験を分析し、建設的なフィードバックを提供してください。
      
      評価基準：
      1. 原因分析の深さ (0-25点): 失敗の根本原因を深く理解しているか
      2. 対策の具体性 (0-25点): 再発防止策が具体的で実行可能か
      3. 学びの言語化力 (0-25点): 経験から得た学びを明確に言語化できているか
      4. 再発防止意識 (0-25点): 同じ失敗を繰り返さない強い意識があるか
      
      必ずJSON形式で以下の情報を返してください：
      {
        "cause_analysis_score": <0-25の整数>,
        "solution_specificity_score": <0-25の整数>,
        "learning_articulation_score": <0-25の整数>,
        "prevention_awareness_score": <0-25の整数>,
        "total_score": <0-100の整数>,
        "feedback_comment": "<200文字以内の建設的なフィードバック>",
        "suggested_category": "<適切なカテゴリ名>"
      }
    MSG

    # メンター人格に応じてトーンを調整
    case personality
    when 'gentle'
      base_message += "\n\nトーン：優しく励ますような温かい言葉遣いで、ポジティブな面を強調してください。"
    when 'strict'
      base_message += "\n\nトーン：厳しく的確に、改善点を明確に指摘してください。甘やかさず成長を促してください。"
    when 'logical'
      base_message += "\n\nトーン：論理的で客観的に、データや事実に基づいて分析してください。感情的にならず冷静に評価してください。"
    when 'balanced'
      base_message += "\n\nトーン：バランスの取れた言葉遣いで、良い点と改善点の両方を公平に評価してください。"
    end

    base_message
  end

  def build_prompt
    <<~PROMPT
      以下の失敗経験を評価してください。

      【タイトル】
      #{post.title}

      【失敗内容】
      #{post.content}

      【原因分析】
      #{post.cause}

      【対策】
      #{post.solution}

      【学び】
      #{post.learning}

      【カテゴリ】
      #{post.category.name}
    PROMPT
  end

  def save_ai_score(response)
    ai_score = post.build_ai_score(
      cause_analysis_score: response['cause_analysis_score'],
      solution_specificity_score: response['solution_specificity_score'],
      learning_articulation_score: response['learning_articulation_score'],
      prevention_awareness_score: response['prevention_awareness_score'],
      total_score: response['total_score'],
      feedback_comment: response['feedback_comment'],
      suggested_category: response['suggested_category'],
      model_version: 'gpt-4-turbo',
      tokens_used: response['tokens_used']
    )

    if ai_score.save
      post.update(ai_evaluated: true, ai_evaluated_at: Time.current)
    end
  end
end