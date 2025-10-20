require 'openai'

class AiIncompleteFeedbackService
  attr_reader :reminder

  def initialize(reminder)
    @reminder = reminder
    @client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])
  end

  def generate_feedback
    return nil unless can_generate?

    begin
      response = request_feedback
      save_feedback(response)
      response
    rescue StandardError => e
      Rails.logger.error "AI Incomplete Feedback Error: #{e.message}"
      nil
    end
  end

  private

  def can_generate?
    ENV['OPENAI_API_KEY'].present? && 
    reminder.has_unchecked_items? &&
    unchecked_items.any?
  end

  def unchecked_items
    @unchecked_items ||= reminder.reflection_items.where(checked: false).ordered
  end

  def checked_items
    @checked_items ||= reminder.reflection_items.where(checked: true).ordered
  end

  def request_feedback
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
    JSON.parse(content)
  end

  def system_message
    personality = reminder.user.mentor_personality
    
    base_message = <<~MSG
      あなたは成長を支援するメンターです。
      ユーザーが振り返りチェックリストを完了できなかった項目について、建設的なフィードバックを提供してください。
      
      【重要な観点】
      - 責めるのではなく、理解と共感を示す
      - なぜチェックできなかったのか、可能性を提示する
      - 次回に向けた具体的で実行可能なアドバイスを提供
      - 完了できた項目は称賛し、モチベーションを維持する
      
      必ずJSON形式で以下の情報を返してください：
      {
        "overall_message": "<全体的なメッセージ（100文字程度）>",
        "praise_points": ["<完了できた点1>", "<完了できた点2>"],
        "unchecked_analysis": [
          {
            "item": "<未完了項目の内容>",
            "possible_reasons": ["<理由1>", "<理由2>"],
            "advice": "<具体的なアドバイス>"
          }
        ],
        "next_steps": ["<次のステップ1>", "<次のステップ2>", "<次のステップ3>"]
      }
    MSG

    # メンター人格に応じてトーンを調整
    case personality
    when 'gentle'
      base_message += "\n\nトーン：優しく励ますように、自己肯定感を高める言葉選びをしてください。"
    when 'strict'
      base_message += "\n\nトーン：厳しくも愛情を持って、真剣に向き合うよう促してください。"
    when 'logical'
      base_message += "\n\nトーン：論理的で客観的に、冷静に分析してください。"
    when 'balanced'
      base_message += "\n\nトーン：バランスの取れた言葉で、実用的なアドバイスをしてください。"
    end

    base_message
  end

  def build_prompt
    post = reminder.post
    
    checked_list = checked_items.map { |item| "✓ #{item.content}" }.join("\n")
    unchecked_list = unchecked_items.map { |item| "□ #{item.content}" }.join("\n")
    
    <<~PROMPT
      【振り返り情報】
      タイミング: #{reminder.reminder_type_name}
      投稿: #{post.title}
      
      【元の失敗内容】
      #{post.content.truncate(500)}
      
      【完了できた項目】（#{checked_items.count}件）
      #{checked_list.presence || "なし"}
      
      【未完了項目】（#{unchecked_items.count}件）
      #{unchecked_list}
      
      上記の未完了項目について、なぜチェックできなかったのか分析し、次回に向けたアドバイスを提供してください。
      完了できた項目についても適切に評価してください。
    PROMPT
  end

  def save_feedback(response)
    reminder.update!(ai_advice: response.to_json)
  end
end

