# Re_Mind

失敗を確実に学びに変える、AI搭載の振り返りアプリケーション

## アプリケーション概要

Re_Mindは、失敗を記録し、AIが即座に評価・フィードバックを提供する振り返りアプリケーションです。忘却曲線に基づく科学的なリマインドシステムにより、継続的な学習を支援します。

### 主な機能
- **失敗ログの記録**: 構造化された振り返りフォーム
- **AI評価システム**: 4つの基準で0-100点評価
- **自動リマインド**: 忘却曲線に基づく5回の振り返り
- **AI総評機能**: 期間ごとの成長分析
- **成長の可視化**: スコア推移グラフと統計ダッシュボード

## URL

**本番環境**: https://re-mind-u6zc.onrender.com/

## テスト用アカウント

### デモユーザー（プレゼン用）
```
Email: demo@remind.com
Password: demo1234
```

### 一般ユーザー
```
Email: test@example.com
Password: password
```

### Basic認証
```
ID: admin
Password: 2222
```

## 利用方法

### 1. アカウント作成・ログイン
- 新規ユーザーは「新規登録」からアカウント作成
- 既存ユーザーは「ログイン」からアクセス

### 2. 失敗ログの投稿
- 「新しい失敗ログを投稿」をクリック
- タイトル、内容、原因、対策、学びを記入
- 「投稿時にAI評価を自動実行する」にチェック
- 「投稿する」をクリック

### 3. AI評価の確認
- 投稿後、即座にAI評価が表示される
- 4つの基準（原因分析、対策具体性、学び言語化、再発防止）でスコア化
- ランク（S〜E）とフィードバックコメントを確認

### 4. 振り返りの実施
- 自動で5回のリマインドが設定される（1日、3日、7日、30日、90日後）
- 各タイミングでAI生成のチェックリストに回答
- 進捗状況をダッシュボードで確認

### 5. 成長の確認
- 「学びの振り返り」ページでAI総評を生成
- スコア推移グラフで成長を可視化
- カテゴリ別の分析を確認

## アプリケーションを作成した背景

### 解決する課題
- **同じ失敗を繰り返す**: 振り返りが表面的で、根本的な改善に至らない
- **振り返りが続かない**: 手動での振り返りは継続が困難
- **成長を実感できない**: 客観的な評価が得られず、成長を実感しにくい
- **学習効果が低い**: 科学的根拠のない振り返り間隔で、学習が定着しない

### ターゲットユーザー
- 自己改善に取り組むビジネスパーソン
- 失敗から学びたい学生・社会人
- 振り返り習慣を身につけたい人
- 成長を可視化したい人

## 実装した機能についての画像やGIFおよびその説明

### 1. AI評価システム
https://gyazo.com/aa28f23147cc44b2342f5ddb839a6b25
- 投稿と同時にAIが4つの基準で評価
- 0-100点のスコアとランク表示
- 具体的なフィードバックコメントを提供

### 2. 自動リマインド機能
![リマインド画面](https://gyazo.com/a00ca4a66d55a4dd17693d2dd796d321)
- 忘却曲線に基づく科学的な振り返り間隔
- AI生成のチェックリストで段階的な振り返り
- 進捗状況の可視化

### 3. AI総評機能
![AI総評画面](https://gyazo.com/0d2954b43bccf7f1ec9eebb3d6962a67)
- 一定期間の投稿をAIが総合分析
- 成長ポイントと改善点を抽出
- パーソナライズされたアドバイスを提供

### 4. 成長の可視化
![ダッシュボード](https://gyazo.com/7ae1aa5d41eaa302ab0e3f69f8cb08cd)
- スコア推移グラフで成長を確認
- カテゴリ別の分析
- 統計情報の表示


## データベース設計

### ER図
```
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
```

### テーブル詳細

#### Userテーブル
| カラム名 | 型 | 制約 | 説明 |
|---------|----|----|-----|
| id | integer | PK | 主キー |
| email | string | null: false, unique: true | ログイン用メールアドレス |
| encrypted_password | string | null: false | パスワード（Devise対応） |
| name | string | | ユーザー名 |
| mentor_personality | string | default: 'balanced' | AIメンターの性格 |

#### Postテーブル
| カラム名 | 型 | 制約 | 説明 |
|---------|----|----|-----|
| id | integer | PK | 主キー |
| user_id | integer | FK, null: false | ユーザーID |
| category_id | integer | FK, null: false | カテゴリID |
| title | string | null: false | 投稿タイトル |
| content | text | null: false | 失敗の内容 |
| cause | text | | 原因分析 |
| solution | text | | 対策・改善策 |
| learning | text | | 得られた学び |
| ai_evaluated | boolean | default: false | AI評価済みフラグ |

#### AiScoreテーブル
| カラム名 | 型 | 制約 | 説明 |
|---------|----|----|-----|
| id | integer | PK | 主キー |
| post_id | integer | FK, null: false | 投稿ID |
| total_score | integer | null: false | 総合スコア（0-100点） |
| cause_analysis_score | integer | | 原因分析の深さスコア（0-25点） |
| solution_specificity_score | integer | | 対策の具体性スコア（0-25点） |
| learning_articulation_score | integer | | 学びの言語化力スコア（0-25点） |
| prevention_awareness_score | integer | | 再発防止意識スコア（0-25点） |
| feedback_comment | text | | AIからのフィードバックコメント |

## 画面遷移図

```
ログイン/新規登録
    ↓
ダッシュボード
    ↓
┌─────────────────┬─────────────────┬─────────────────┐
│ 新しい投稿      │ 投稿一覧        │ 学びの振り返り   │
│    ↓            │    ↓            │    ↓            │
│ 投稿フォーム    │ 投稿詳細        │ 振り返りページ   │
│    ↓            │    ↓            │    ↓            │
│ AI評価表示      │ リマインダー    │ AI総評生成      │
└─────────────────┴─────────────────┴─────────────────┘
    ↓
リマインダー詳細
    ↓
チェックリスト回答
```

## 開発環境

- **言語**: Ruby 3.2.0
- **フレームワーク**: Ruby on Rails 7.0.8
- **データベース**: PostgreSQL
- **フロントエンド**: HTML, CSS, JavaScript
- **AI**: OpenAI GPT-4 Turbo
- **デプロイ**: Render
- **認証**: Devise
- **UI**: カスタムCSS（Tailwind CSS風）

## ローカルでの動作方法

### 1. リポジトリのクローン
```bash
git clone https://github.com/your-username/Re_Mind.git
cd Re_Mind
```

### 2. 依存関係のインストール
```bash
bundle install
```

### 3. データベースのセットアップ
```bash
rails db:create
rails db:migrate
rails db:seed
```

### 4. 環境変数の設定
```bash
# .envファイルを作成
OPENAI_API_KEY=your_openai_api_key
```

### 5. サーバーの起動
```bash
rails server
```

### 6. ブラウザでアクセス
```
http://localhost:3000
```

## 工夫したポイント

### 1. AI評価システムの精度向上
- 4つの明確な評価基準を設定
- ユーザーのメンター人格に応じたフィードバック調整
- プロンプトエンジニアリングによる一貫性の確保

### 2. 科学的根拠に基づく設計
- エビングハウスの忘却曲線を活用した振り返り間隔
- 認知科学に基づく学習効果の最大化

### 3. 継続を促すUX設計
- ゲーミフィケーション（ランク、スコア）
- 自動リマインドによる手間の削減
- 成長の可視化によるモチベーション維持

### 4. 技術的な工夫
- 非同期処理によるAI評価の高速化
- レスポンシブデザインによるモバイル対応
- セキュリティを考慮した認証システム

## 改善点

### 1. パフォーマンスの最適化
- AI評価の並列処理による高速化
- データベースクエリの最適化
- キャッシュ機能の実装

### 2. ユーザビリティの向上
- より直感的なUI/UX設計
- 音声入力機能の追加

### 3. 機能の拡張
- 多言語対応
- より詳細な分析機能

## 制作時間

**総制作時間**: 約60時間

- **要件定義・設計**: 3時間
- **フロントエンド開発**: 6時間
- **バックエンド開発**: 20時間
- **AI機能実装**: 20時間
- **テスト・デバッグ**: 10時間

---
