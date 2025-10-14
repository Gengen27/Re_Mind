# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "🌱 Starting seed data..."

# カテゴリの作成
puts "Creating categories..."
Category.seed_default_categories
puts "✅ Created #{Category.count} categories"

# 開発環境用のテストユーザー作成
if Rails.env.development?
  puts "\n📝 Creating test user for development..."
  
  test_user = User.find_or_create_by(email: 'test@example.com') do |user|
    user.password = 'password'
    user.password_confirmation = 'password'
    user.name = 'テストユーザー'
    user.mentor_personality = 'balanced'
  end
  
  puts "✅ Test user created: #{test_user.email}"
  puts "   Password: password"
  
  # サンプル投稿の作成
  if test_user.posts.empty?
    puts "\n📝 Creating sample posts..."
    
    work_category = Category.find_by(name: '仕事')
    study_category = Category.find_by(name: '勉強')
    
    post1 = test_user.posts.create!(
      title: 'プロジェクトの締切に遅れてしまった',
      content: '重要なプロジェクトの締切に2日遅れてしまい、チーム全体に迷惑をかけてしまった。',
      cause: 'タスクの見積もりが甘く、予期せぬバグの修正に時間を取られた。また、途中で仕様変更があったが、それを加味した再見積もりをしなかった。',
      solution: '今後はバッファを20%程度設けること。また、仕様変更時には必ず影響範囲を確認し、スケジュールの再調整を行う。',
      learning: 'スケジュール管理は楽観的にならず、リスクを考慮することが重要。早めの報連相が信頼を守ることにつながる。',
      category: work_category,
      occurred_at: 3.days.ago
    )
    
    post2 = test_user.posts.create!(
      title: 'プレゼンで緊張して内容を忘れてしまった',
      content: '大事なプレゼンで緊張のあまり、準備していた内容の一部を忘れてしまった。',
      cause: '練習不足と、台本に頼りすぎていた。また、深呼吸などのリラックス方法を知らなかった。',
      solution: '本番前に最低5回は通しで練習する。また、プレゼン前の呼吸法やリラックステクニックを学ぶ。',
      learning: '準備は裏切らない。場数を踏むことで緊張にも慣れることができる。',
      category: work_category,
      occurred_at: 1.week.ago
    )
    
    post3 = test_user.posts.create!(
      title: '英語の試験対策が不十分で不合格',
      content: 'TOEICの目標スコアに50点届かず、不合格となってしまった。',
      cause: '計画的な学習ができず、試験直前に詰め込もうとした。特にリスニングの練習が不足していた。',
      solution: '毎日30分の学習時間を確保し、特に苦手分野を重点的に学習する。模擬試験も定期的に受ける。',
      learning: '短期間の詰め込みでは実力はつかない。継続的な努力が重要。',
      category: study_category,
      occurred_at: 2.weeks.ago
    )
    
    puts "✅ Created #{test_user.posts.count} sample posts"
  end
end

puts "\n🎉 Seed data completed!"
puts "=" * 50