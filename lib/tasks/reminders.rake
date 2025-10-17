namespace :reminders do
  desc "振り返りリマインドの状態を更新（scheduled_dateが今日以前のものをreadyに変更）"
  task update_status: :environment do
    puts "=" * 60
    puts "振り返りリマインド状態更新タスク開始"
    puts "実行時刻: #{Time.current.strftime('%Y-%m-%d %H:%M:%S')}"
    puts "=" * 60
    
    # scheduled_dateが今日以前で、statusがpendingのリマインドを取得
    pending_reminders = Reminder.where(status: 'pending')
                                .where('scheduled_date <= ?', Date.current)
    
    count = pending_reminders.count
    puts "\n対象リマインド数: #{count}件"
    
    if count.zero?
      puts "更新対象のリマインドはありません"
    else
      # statusをreadyに更新
      updated_count = 0
      
      pending_reminders.find_each do |reminder|
        if reminder.total_items_count.zero?
          puts "  [スキップ] ID: #{reminder.id} - チェックリストが未生成"
          next
        end
        
        reminder.mark_as_ready!
        updated_count += 1
        
        puts "  [更新] ID: #{reminder.id}"
        puts "    投稿: #{reminder.post.title}"
        puts "    タイプ: #{reminder.reminder_type_name}"
        puts "    予定日: #{reminder.scheduled_date}"
      end
      
      puts "\n✓ #{updated_count}件のリマインドを更新しました"
    end
    
    puts "\n" + "=" * 60
    puts "タスク完了"
    puts "=" * 60
  end
  
  desc "未完了のリマインドを再通知対象にする"
  task retry_incomplete: :environment do
    puts "=" * 60
    puts "未完了リマインド再通知タスク開始"
    puts "実行時刻: #{Time.current.strftime('%Y-%m-%d %H:%M:%S')}"
    puts "=" * 60
    
    # in_progressで3日以上経過したリマインドを取得
    incomplete_reminders = Reminder.where(status: 'in_progress')
                                   .where('updated_at < ?', 3.days.ago)
                                   .where('retry_count < ?', 3)
    
    count = incomplete_reminders.count
    puts "\n対象リマインド数: #{count}件"
    
    if count.zero?
      puts "再通知対象のリマインドはありません"
    else
      incomplete_reminders.find_each do |reminder|
        # retry_countを増やしてreadyに戻す
        reminder.update!(
          status: 'ready',
          retry_count: reminder.retry_count + 1
        )
        
        puts "  [再通知] ID: #{reminder.id}"
        puts "    投稿: #{reminder.post.title}"
        puts "    タイプ: #{reminder.reminder_type_name}"
        puts "    再挑戦回数: #{reminder.retry_count}"
      end
      
      puts "\n✓ #{count}件のリマインドを再通知対象にしました"
    end
    
    puts "\n" + "=" * 60
    puts "タスク完了"
    puts "=" * 60
  end
  
  desc "統計情報を表示"
  task stats: :environment do
    puts "=" * 60
    puts "振り返りリマインド統計"
    puts "=" * 60
    
    total = Reminder.count
    pending = Reminder.pending.count
    ready = Reminder.ready.count
    in_progress = Reminder.in_progress.count
    completed = Reminder.completed.count
    
    puts "\n【ステータス別】"
    puts "  総数:         #{total}件"
    puts "  待機中:       #{pending}件 (pending)"
    puts "  振り返り可能: #{ready}件 (ready)"
    puts "  進行中:       #{in_progress}件 (in_progress)"
    puts "  完了:         #{completed}件 (completed)"
    
    puts "\n【タイプ別】"
    %w[day_1 day_3 day_7 day_30 day_90].each do |type|
      count = Reminder.where(reminder_type: type).count
      completed_count = Reminder.where(reminder_type: type, status: 'completed').count
      completion_rate = count > 0 ? (completed_count.to_f / count * 100).round(1) : 0
      
      type_name = case type
                  when 'day_1' then '1日後'
                  when 'day_3' then '3日後'
                  when 'day_7' then '7日後'
                  when 'day_30' then '30日後'
                  when 'day_90' then '90日後'
                  end
      
      puts "  #{type_name}: #{count}件 (完了率: #{completion_rate}%)"
    end
    
    puts "\n【今日の振り返り予定】"
    today_reminders = Reminder.where(scheduled_date: Date.current)
    puts "  #{today_reminders.count}件"
    
    puts "\n【明日の振り返り予定】"
    tomorrow_reminders = Reminder.where(scheduled_date: Date.current + 1.day)
    puts "  #{tomorrow_reminders.count}件"
    
    puts "\n" + "=" * 60
  end
  
  desc "すべてのリマインド処理を実行（update_status + retry_incomplete）"
  task process_all: :environment do
    Rake::Task['reminders:update_status'].invoke
    puts "\n"
    Rake::Task['reminders:retry_incomplete'].invoke
  end
end

