class CreateReminders < ActiveRecord::Migration[7.1]
  def change
    create_table :reminders do |t|
      t.references :post, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      
      t.string :reminder_type, null: false # 'day_1', 'day_3', 'day_7', 'day_30', 'day_90'
      t.date :scheduled_date, null: false # 振り返り予定日
      t.datetime :completed_at # 全項目チェック完了した日時
      
      t.string :status, default: 'pending', null: false # 'pending', 'ready', 'in_progress', 'completed'
      
      t.integer :checked_items_count, default: 0, null: false # チェック済み項目数
      t.integer :total_items_count, default: 0, null: false # 総項目数
      
      t.integer :retry_count, default: 0, null: false # 再挑戦の回数
      t.text :ai_advice # AIが生成したアドバイス（JSON形式）

      t.timestamps
    end

    add_index :reminders, [:user_id, :status]
    add_index :reminders, [:scheduled_date, :status]
    add_index :reminders, :reminder_type
  end
end

