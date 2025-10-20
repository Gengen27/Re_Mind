# 振り返りリマインドタスク

## 概要

このタスクは、振り返りリマインドの状態を自動的に更新します。

## タスク一覧

### 1. `rails reminders:update_status`

scheduled_dateが今日以前のリマインドを`ready`状態に更新します。

**実行タイミング**: 毎日1回（推奨: 毎朝0時）

**動作**:
- `status = 'pending'` かつ `scheduled_date <= 今日` のリマインドを検索
- チェックリストが生成されているもの（`total_items_count > 0`）のみ更新
- `status`を`ready`に変更

**実行例**:
```bash
rails reminders:update_status
```

**出力例**:
```
============================================================
振り返りリマインド状態更新タスク開始
実行時刻: 2025-10-17 00:00:00
============================================================

対象リマインド数: 3件
  [更新] ID: 15
    投稿: 会議で資料を忘れた
    タイプ: 1日後
    予定日: 2025-10-16
  [更新] ID: 16
    投稿: 会議で資料を忘れた
    タイプ: 3日後
    予定日: 2025-10-14
  [更新] ID: 23
    投稿: コードレビューでの指摘漏れ
    タイプ: 7日後
    予定日: 2025-10-10

✓ 3件のリマインドを更新しました

============================================================
タスク完了
============================================================
```

---

### 2. `rails reminders:retry_incomplete`

長期間未完了のリマインドを再通知対象にします。

**実行タイミング**: 毎日1回（推奨: 毎朝0時）

**動作**:
- `status = 'in_progress'` かつ 3日間更新なし かつ `retry_count < 3`
- `status`を`ready`に戻す
- `retry_count`を+1

**実行例**:
```bash
rails reminders:retry_incomplete
```

---

### 3. `rails reminders:stats`

現在のリマインド統計を表示します。

**実行タイミング**: 手動（必要に応じて）

**実行例**:
```bash
rails reminders:stats
```

**出力例**:
```
============================================================
振り返りリマインド統計
============================================================

【ステータス別】
  総数:         50件
  待機中:       20件 (pending)
  振り返り可能: 5件 (ready)
  進行中:       3件 (in_progress)
  完了:         22件 (completed)

【タイプ別】
  1日後: 10件 (完了率: 40.0%)
  3日後: 10件 (完了率: 50.0%)
  7日後: 10件 (完了率: 60.0%)
  30日後: 10件 (完了率: 70.0%)
  90日後: 10件 (完了率: 80.0%)

【今日の振り返り予定】
  3件

【明日の振り返り予定】
  5件

============================================================
```

---

### 4. `rails reminders:process_all`

すべてのリマインド処理を一度に実行します（`update_status` + `retry_incomplete`）。

**実行タイミング**: 毎日1回（推奨: 毎朝0時）

**実行例**:
```bash
rails reminders:process_all
```

---

## 定期実行の設定

### 方法1: Cron（本番環境推奨）

`crontab -e`で以下を追加：

```cron
# 毎日午前0時に実行
0 0 * * * cd /path/to/Re_Mind && RAILS_ENV=production bundle exec rails reminders:process_all >> log/reminders_cron.log 2>&1
```

### 方法2: Whenever gem（推奨）

1. Gemfileに追加：
```ruby
gem 'whenever', require: false
```

2. `config/schedule.rb`を作成：
```ruby
set :output, "log/whenever.log"

every 1.day, at: '12:00 am' do
  rake "reminders:process_all"
end
```

3. crontabに書き込み：
```bash
bundle exec whenever --update-crontab
```

### 方法3: Heroku Scheduler（Heroku使用時）

Heroku Schedulerアドオンを追加：
```bash
heroku addons:create scheduler:standard
heroku addons:open scheduler
```

Web UIで以下のコマンドを設定：
```
rails reminders:process_all
```
頻度: Daily (毎日)

### 方法4: Render Cron Jobs（Render使用時・推奨）

#### A. render.yaml で自動設定（推奨）

プロジェクトルートに`render.yaml`を作成（すでに作成済み）：

```yaml
services:
  - type: cron
    name: reminders-update
    env: ruby
    schedule: "0 15 * * *"  # UTC 15時 = JST 0時
    buildCommand: "./bin/render-build.sh"
    startCommand: "bundle exec rails reminders:process_all"
    envVars:
      - key: DATABASE_URL
        fromDatabase:
          name: re-mind-db
          property: connectionString
```

Git push後、Renderが自動的にCron Jobを作成します。

#### B. Web UIで手動設定

1. Renderダッシュボードにログイン
2. "New +" → "Cron Job"
3. 設定:
   - Command: `bundle exec rails reminders:process_all`
   - Schedule: `0 15 * * *`（JST 0時の場合）
4. 環境変数を設定して保存

**タイムゾーン注意**: RenderはUTCで動作（JST = UTC + 9時間）

### 方法5: 手動実行（開発環境）

開発中は手動で実行：
```bash
# 毎日手動で実行
rails reminders:process_all

# または個別に
rails reminders:update_status
rails reminders:retry_incomplete
```

---

## トラブルシューティング

### Q: タスクが動作しない

**確認事項**:
1. データベースに接続できるか
   ```bash
   rails db:migrate:status
   ```

2. Reminderモデルが存在するか
   ```bash
   rails console
   > Reminder.count
   ```

3. エラーログを確認
   ```bash
   tail -f log/production.log
   ```

### Q: チェックリストが未生成のリマインドがある

タスク実行時に以下のようなメッセージが表示されます：
```
[スキップ] ID: 15 - チェックリストが未生成
```

**原因**: 投稿時にAIチェックリスト生成が失敗した

**対処法**:
1. 手動でチェックリストを生成
   ```bash
   rails console
   > post = Post.find(XXX)
   > AiReflectionChecklistService.new(post).generate
   ```

2. または投稿の編集画面から手動で項目を追加

### Q: retry_countが3に達したリマインド

再通知が3回行われても未完了の場合、それ以上自動再通知されません。

**対処法**:
- ユーザーが自分で振り返り一覧から確認
- または手動でretry_countをリセット

---

## 開発中のテスト

### 動作確認

1. テスト用の投稿を作成
2. scheduled_dateを過去の日付に変更
   ```bash
   rails console
   > reminder = Reminder.last
   > reminder.update(scheduled_date: Date.current - 1.day)
   ```
3. タスクを実行
   ```bash
   rails reminders:update_status
   ```
4. statusが`ready`に変わることを確認

---

## ログ出力

タスク実行時のログは以下に出力されます：

- 標準出力: コンソールに表示
- cronログ: `log/reminders_cron.log`（cron設定時）
- Railsログ: `log/production.log`

ログレベルを調整する場合は`config/environments/production.rb`で設定：
```ruby
config.log_level = :info
```

