# README

1. Userテーブル（ユーザー）
| カラム名                | 型       | 制約                      | 説明                           |
| ---------------------- | -------- | ------------------------- | ----------------------------- |
| id                     | integer  | PK                        | 主キー                         |
| email                  | string   | null: false, unique: true | ログイン用メールアドレス         |
| encrypted_password     | string   | null: false               | パスワード（Devise対応）        |
| reset_password_token   | string   | unique: true              | パスワードリセット用トークン     |
| reset_password_sent_at | datetime |                           | パスワードリセットメール送信日時 |
| remember_created_at    | datetime |                           | ログイン状態保持の作成日時       |
| sign_in_count          | integer  | default: 0                | ログイン回数                    |
| current_sign_in_at     | datetime |                           | 現在のログイン日時              |
| last_sign_in_at        | datetime |                           | 最後のログイン日時              |
| current_sign_in_ip     | string   |                           | 現在のログインIPアドレス         |
| last_sign_in_ip        | string   |                           | 最後のログインIPアドレス         |
| name                   | string   |                           | ユーザー名                      |
| mentor_personality     | string   | default: 'balanced'       | AIメンターの性格                |
| reminder_enabled       | boolean  | default: false            | リマインダー機能の有効/無効      |
| reminder_interval_days | integer  | default: 7                | リマインダーの間隔（日数）       |
| created_at             | datetime | null: false               | レコード作成日時（自動生成）      |
| updated_at             | datetime | null: false               | レコード更新日時（自動更新）      |

# association
has_many :posts, dependent: :destroy

2. Categoryテーブル（カテゴリ）
| カラム名     | 型       | 制約                      | 説明                               |
| ----------- | -------- | ------------------------- | ---------------------------------- |
| id          | integer  | PK                        | 主キー                             |
| name        | string   | null: false, unique: true | カテゴリ名（例: 仕事、勉強）         |
| color       | string   | default: '#6B7280'      | 表示用カラーコード（例: #3B82F6） |
| description | text     |                           | カテゴリの説明                      |
| created_at  | datetime | null: false               | レコード作成日時（自動生成）         |
| updated_at  | datetime | null: false               | レコード更新日時（自動更新）         |

# association
has_many :posts, dependent: :destroy 

3. Postテーブル（投稿）
| カラム名          | 型       | 制約                           | 説明                           |
| ---------------- | -------- | ------------------------------ | ----------------------------- |
| id               | integer  | PK                             | 主キー                         |
| user_id          | integer  | FK, null: false, index: true   | ユーザーID（外部キー）          |
| category_id      | integer  | FK, null: false, index: true   | カテゴリID（外部キー）          |
| title            | string   | null: false                    | 投稿タイトル                   |
| content          | text     | null: false                    | 失敗の内容                     |
| cause            | text     |                                | 原因分析                       |
| solution         | text     |                                | 対策・改善策                   |
| learning         | text     |                                | 得られた学び                   |
| occurred_at      | date     |                                | 失敗が発生した日               |
| ai_evaluated     | boolean  | default: false                 | AI評価済みフラグ               |
| ai_evaluated_at  | datetime |                                | AI評価実行日時                 |
| created_at       | datetime | null: false                    | レコード作成日時（自動生成）     |
| updated_at       | datetime | null: false                    | レコード更新日時（自動更新）     |

# association
belongs_to :user
belongs_to :category
has_one :ai_score, dependent: :destroy

4. AiScoreテーブル（AI評価）
| カラム名                       | 型       | 制約                         | 説明                             |
| ----------------------------- | -------- | ---------------------------- | ------------------------------- |
| id                            | integer  | PK                           | 主キー                           |
| post_id                       | integer  | FK, null: false, index: true | 投稿ID（外部キー）                |
| total_score                   | integer  | null: false                  | 総合スコア（0-100点）             |
| cause_analysis_score          | integer  |                              | 原因分析の深さスコア（0-25点）     |
| solution_specificity_score    | integer  |                              | 対策の具体性スコア（0-25点）       |
| learning_articulation_score   | integer  |                              | 学びの言語化力スコア（0-25点）     |
| prevention_awareness_score    | integer  |                              | 再発防止意識スコア（0-25点）       |
| feedback_comment              | text     |                              | AIからのフィードバックコメント     |
| suggested_category            | string   |                              | AIが提案するカテゴリ              |
| model_version                 | string   | default: 'gpt-4-turbo'       | 使用したAIモデルのバージョン       |
| tokens_used                   | integer  |                              | API使用トークン数                 |
| created_at                    | datetime | null: false                  | レコード作成日時（自動生成）       |
| updated_at                    | datetime | null: false                  | レコード更新日時（自動更新）       |

# association
belongs_to :post


## ER図 （リレーション）

┌─────────────────┐
│     User        │
│─────────────────│
│ id (PK)         │
│ email           │
│ name            │
│ mentor_personality │
└─────────────────┘
        │
        │ 1
        │
        │ has_many
        │
        ↓ *
┌─────────────────┐         ┌─────────────────┐
│     Post        │ * ───→ 1│    Category     │
│─────────────────│ belongs_to │─────────────────│
│ id (PK)         │         │ id (PK)         │
│ user_id (FK)    │         │ name            │
│ category_id (FK)│         │ color           │
│ title           │         │ description     │
│ content         │         └─────────────────┘
│ cause           │
│ solution        │
│ learning        │
│ ai_evaluated    │
└─────────────────┘
        │
        │ 1
        │
        │ has_one
        │
        ↓ 1
┌─────────────────┐
│    AiScore      │
│─────────────────│
│ id (PK)         │
│ post_id (FK)    │
│ total_score     │
│ cause_analysis_score │
│ solution_specificity_score │
│ learning_articulation_score │
│ prevention_awareness_score │
│ feedback_comment │
│ model_version   │
└─────────────────┘

