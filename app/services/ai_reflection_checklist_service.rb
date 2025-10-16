require 'openai'

class AiReflectionChecklistService
  attr_reader :post

  def initialize(post)
    @post = post
    @client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])
  end

  def generate
    return false unless can_generate?

    begin
      response = request_checklist_generation
      save_reflection_items(response)
      true
    rescue StandardError => e
      Rails.logger.error "AI Reflection Checklist Generation Error: #{e.message}"
      false
    end
  end

  private

  def can_generate?
    ENV['OPENAI_API_KEY'].present? && 
    post.content.present? && 
    post.cause.present? && 
    post.solution.present?
  end

  def request_checklist_generation
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
    personality = post.user.mentor_personality
    
    base_message = <<~MSG
      あなたは成長をサポートするメンターです。
      ユーザーの失敗記録について、振り返り用のチェックリストを作成してください。

      【重要な要件】
      - ユーザーがまだ同じ場面に遭遇していなくても答えられる質問にすること
      - 「実践できたか」ではなく「覚えているか」「理解しているか」「準備できているか」を問う
      - チェックボックスで答えられる形式（〜か？で終わる）
      - 各項目は50文字以内で簡潔に

      【各タイミングの目的】
      1日後：記憶の定着
      - この失敗の原因や対策を覚えているか確認
      - 学びが明確になっているか確認
      - 3-4項目

      3日後：理解の深化
      - 根本原因を理解しているか確認
      - 他の場面への応用可能性を考えているか確認
      - 3-4項目

      7日後：意識と準備
      - この学びを日常で意識できているか確認
      - 次に活かす準備ができているか確認
      - 3-4項目

      30日後：習慣化の確認
      - 自然と意識できるようになっているか確認
      - 成長を実感しているか確認
      - 3-4項目

      90日後：長期的な変化
      - この失敗が成長の一部になっているか確認
      - 他の場面にも応用できているか確認
      - 3-4項目

      必ずJSON形式で以下の情報を返してください：
      {
        "day_1": [
          {"content": "チェック項目", "item_type": "memory"},
          ...
        ],
        "day_3": [
          {"content": "チェック項目", "item_type": "awareness"},
          ...
        ],
        "day_7": [...],
        "day_30": [...],
        "day_90": [...]
      }

      item_typeは以下から選択：
      - memory: 記憶・理解系
      - awareness: 意識・気づき系
      - growth: 成長実感系
    MSG

    # メンター人格に応じてトーンを調整
    case personality
    when 'gentle'
      base_message += "\n\nトーン：優しく前向きな質問で、自己肯定感を高めるような内容にしてください。"
    when 'strict'
      base_message += "\n\nトーン：厳しく本質を問う質問で、真剣に向き合わせる内容にしてください。"
    when 'logical'
      base_message += "\n\nトーン：論理的で客観的な質問で、冷静に分析できる内容にしてください。"
    when 'balanced'
      base_message += "\n\nトーン：バランスの取れた質問で、実用的な内容にしてください。"
    end

    base_message
  end

  def build_prompt
    <<~PROMPT
      以下の失敗記録について、振り返り用のチェックリストを作成してください。

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

  def save_reflection_items(response)
    # 各リマインダーに対してチェックリスト項目を作成
    post.reminders.each do |reminder|
      items_data = response[reminder.reminder_type]
      next unless items_data.present?

      items_data.each_with_index do |item_data, index|
        reminder.reflection_items.create!(
          post: post,
          content: item_data['content'],
          item_type: item_data['item_type'],
          position: index,
          ai_generated: true,
          checked: false
        )
      end

      # total_items_countを更新
      reminder.update!(total_items_count: items_data.length)
    end
  end
end

