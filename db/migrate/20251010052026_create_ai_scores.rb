class CreateAiScores < ActiveRecord::Migration[7.1]
  def change
    create_table :ai_scores do |t|
      t.references :post, null: false, foreign_key: true
      
      t.integer :total_score, null: false # 総合スコア 0-100
      t.integer :cause_analysis_score # 原因分析の深さ 0-25
      t.integer :solution_specificity_score # 対策の具体性 0-25
      t.integer :learning_articulation_score # 学びの言語化力 0-25
      t.integer :prevention_awareness_score # 再発防止意識 0-25
      
      t.text :feedback_comment # AIのフィードバックコメント
      t.string :suggested_category # AIが提案するカテゴリ
      
      t.string :model_version, default: 'gpt-4-turbo' # 使用したAIモデル
      t.integer :tokens_used # 使用トークン数

      t.timestamps
    end

    add_index :ai_scores, :total_score
    add_index :ai_scores, :created_at
  end
end
