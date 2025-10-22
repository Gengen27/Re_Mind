namespace :demo do
  desc "デモ用のユーザーと投稿データを作成"
  task setup: :environment do
    puts "🎬 デモデータのセットアップを開始します..."
    puts "=" * 60
    
    # デモユーザーの作成
    demo_user = User.find_or_create_by!(email: 'demo@remind.com') do |user|
      user.password = 'demo1234'
      user.password_confirmation = 'demo1234'
      user.name = 'デモユーザー'
      user.mentor_personality = 'balanced'
    end
    
    puts "✅ デモユーザーを作成しました"
    puts "   Email: #{demo_user.email}"
    puts "   Password: demo1234"
    puts ""
    
    # 既存の投稿をクリア
    if demo_user.posts.any?
      demo_user.posts.destroy_all
      puts "🗑️  既存のデモデータを削除しました"
      puts ""
    end
    
    # カテゴリの取得
    work = Category.find_by(name: '仕事')
    study = Category.find_by(name: '勉強')
    health = Category.find_by(name: '健康')
    relationship = Category.find_by(name: '人間関係')
    money = Category.find_by(name: 'お金')
    
    puts "📝 デモ投稿を作成中..."
    
    # ============================================
    # 50点程度の投稿（改善の余地がある例）
    # ============================================
    
    post_low_1 = demo_user.posts.create!(
      title: 'プレゼン資料を期限までに完成できなかった',
      content: '重要なプレゼンの資料を期限までに完成できず、前日の夜に上司に延期をお願いすることになった。結果的にプレゼンは延期になったが、信頼を失った。',
      cause: '時間が足りなかった。仕事が忙しくて資料作成に時間を割けなかった。もっと早く始めるべきだった。',
      solution: '次はもっと早めに取り掛かる。計画的に進める。スケジュールを立てる。',
      learning: '余裕を持って作業することが大切だと分かった。計画性が重要。',
      category: work,
      occurred_at: 10.days.ago
    )
    
    post_low_2 = demo_user.posts.create!(
      title: '顧客への返信を忘れてクレームになった',
      content: '顧客からの問い合わせメールに返信するのを忘れていて、3日後に「まだ返事がない」とクレームの電話がきた。顧客は不満そうだった。',
      cause: 'メールをチェックしたけど、後で返信しようと思って忘れた。他の業務に追われていた。',
      solution: 'メールはすぐに返信する。忘れないように気をつける。',
      learning: '顧客対応は重要だということを学んだ。忘れないようにしないといけない。',
      category: work,
      occurred_at: 15.days.ago
    )
    
    post_low_3 = demo_user.posts.create!(
      title: 'ダイエットを始めたが1週間で挫折',
      content: '健康のためにダイエットを始めたが、1週間で挫折してしまった。食事制限がつらくて続かなかった。',
      cause: '目標が高すぎた。我慢できなかった。',
      solution: '無理のない目標を立てる。',
      learning: '継続が大事。',
      category: health,
      occurred_at: 20.days.ago
    )
    
    # ============================================
    # 80点以上の高スコア投稿（優秀な振り返り例）
    # ============================================
    
    post_high_1 = demo_user.posts.create!(
      title: 'システム障害の初動対応で判断ミス',
      content: 'ECサイトで本番環境のシステム障害が発生した際、原因の特定を急ぐあまり、まず顧客への告知と一時的な回避策の案内を行わなかった。結果として約30分間、顧客からの問い合わせが殺到し、カスタマーサポートがパンク状態になった。最終的には1時間後に復旧したが、顧客満足度に大きな影響を与えた。',
      cause: '根本原因を3つの観点で分析した。①技術面：障害発生時のエスカレーションフローが明文化されておらず、誰が何をすべきか不明確だった。②心理面：エンジニアとしての責任感から「すぐに直さなければ」という焦りが、冷静な判断を妨げた。③組織面：障害対応の優先順位（顧客コミュニケーション → 影響範囲の特定 → 復旧作業）が共有されていなかった。特に、過去の小規模障害で「すぐ直せた」成功体験が、今回の判断を誤らせた要因と考えられる。',
      solution: '具体的な再発防止策を5つ設定。①障害対応マニュアルの作成（15分以内にステータスページ更新、30分以内に詳細告知）②週次で障害対応のシミュレーション訓練を実施③Slackの障害対応専用チャンネルで、時系列のアクションログを残すルールの徹底④PM・CSチームとの連携フローを明文化し、壁に掲示⑤毎月1回、過去の障害事例を振り返る定例会を設置。さらに、個人として「5分考えて解決策が見えなければ、まず影響を最小化する行動を取る」というルールを手帳に記載し、毎朝確認する。',
      learning: '障害対応において最も重要なのは「顧客への影響を最小化すること」であり、「技術的に完璧に直すこと」ではない。この優先順位の違いを体で理解した。また、焦りは思考を狭める。冷静さを保つためには、事前の準備（マニュアル、訓練）が不可欠。さらに、この経験から「失敗したときこそ、まず全体を俯瞰する」という思考習慣を身につけることができた。この教訓は、障害対応だけでなく、プロジェクト全般で応用できる普遍的な学びだと感じている。',
      category: work,
      occurred_at: 7.days.ago
    )
    
    post_high_2 = demo_user.posts.create!(
      title: 'チームメンバーとのコミュニケーション不足でタスクが重複',
      content: '新機能開発のプロジェクトで、自分と後輩が同じAPIの実装を進めていたことが、コードレビューの段階で発覚。2人で4日分の工数が無駄になった。さらに、マージ時のコンフリクト解消に半日を費やし、リリーススケジュールが1日遅延した。',
      cause: '表面的には「タスク管理ツールの更新漏れ」だが、5回のWhy分析を実施した結果、より深い原因が見えた。なぜタスクが重複？→管理ツールを更新していなかった。なぜ更新しなかった？→忙しくて後回しにした。なぜ後回しに？→更新の重要性を認識していなかった。なぜ認識していなかった？→過去に重複が起きたことがなく、危機感がなかった。なぜ危機感がなかった？→チーム内で「タスク管理の目的」が共有されていなかった。本質的な原因は、「タスク管理ツールは管理のためではなく、チーム全体の生産性向上のため」という目的意識の欠如だった。',
      solution: '短期・中期・長期で対策を設計。【短期（即日実施）】毎朝の5分ミーティングで、全員が今日やることを口頭で共有し、重複をその場で検出。【中期（1週間以内）】タスク管理ツール（Trello）のボードを再設計。「未着手」「進行中」「レビュー待ち」の3列構造に変更し、誰が何をしているか視覚的に分かるようにする。さらに、タスクの担当者を必ず設定するルールを導入。【長期（1ヶ月以内）】チーム全体で「なぜタスク管理をするのか」というワークショップを開催し、目的意識を共有。また、毎週金曜日に「今週の改善点」を1つずつ出し合い、プロセス改善を習慣化する。',
      learning: 'この失敗から3つの重要な学びを得た。①ツールは使うだけでは意味がなく、「なぜ使うのか」という目的理解が本質。②チームの生産性は、個人のスキルよりも「情報共有の質」に大きく依存する。③失敗を防ぐには、過去の成功体験に安住せず、「起きていないリスク」にも目を向ける想像力が必要。この経験は、今後リーダーになった時に「チームの仕組み作り」の重要性を説く際の、具体的なエピソードとして活用できる。失敗は、確実に自分を成長させる最高の教材だと実感した。',
      category: work,
      occurred_at: 5.days.ago
    )
    
    post_high_3 = demo_user.posts.create!(
      title: '資格試験の勉強法を見誤り、不合格に',
      content: '情報処理技術者試験の高度試験に挑戦したが、午後問題で時間が足りず、最後の大問を白紙で提出。結果は不合格（合格まであと5点）。3ヶ月間、平日2時間・休日5時間を費やしたが、報われなかった。',
      cause: '勉強方法の選択ミスを多角的に分析。①インプット過多：参考書を読むことに時間を割きすぎ、アウトプット（過去問演習）が全体の30%程度だった。合格者の多くは70%がアウトプットと聞き、バランスが逆だったことに気づいた。②時間配分の練習不足：過去問は解いていたが、時間を測っての演習が少なかった。そのため、本番で「どの問題に何分使うべきか」の感覚が身についていなかった。③メタ認知の欠如：「理解している」と思っていたが、実際には「読んだことがある」だけの状態。自分の理解度を客観的に測る仕組み（小テスト、説明練習など）を取り入れていなかった。④目標設定のミス：「合格する」という結果目標だけで、「毎日過去問を3問解く」といったプロセス目標が不明確だった。',
      solution: '次回の試験（6ヶ月後）に向けた学習計画を再設計。①インプット3割：アウトプット7割の比率を厳守。参考書は辞書的に使い、基本は過去問ベース。②毎週日曜日に本番形式の模擬試験（150分計測）を実施し、時間配分の感覚を養う。③毎日の学習後に「今日学んだことを誰かに説明するつもりでノートに書く」ことで理解度を確認。④1日単位の具体的な目標を設定（例：「午後問題の過去問を2問、時間を測って解く」）し、Notionで進捗を可視化。⑤月1回、同じ試験を目指す勉強仲間とオンライン勉強会を開催し、互いに問題を出し合う。⑥不合格という結果を受け入れつつも、「次回は必ず合格する」という明確なコミットメントを、SNSで宣言して後に引けない状況を作る。',
      learning: '失敗から3つの深い学びを得た。①学習において「量」より「質」が重要。特に、理解したつもりになる「わかったつもり病」を防ぐためには、アウトプット中心の学習が不可欠。②努力の方向性を間違えると、どれだけ時間を使っても結果は出ない。だからこそ、学習初期に「合格者の戦略」をリサーチすることが最重要。③失敗は、正しい方向を教えてくれるコンパス。今回の不合格で、自分の弱点（時間配分、メタ認知不足）が明確になった。次回は確実に合格できる自信がある。この経験は、資格試験に限らず、あらゆる目標達成において「PDCAを回すこと」「戦略を持つこと」の重要性を教えてくれた。',
      category: study,
      occurred_at: 3.days.ago
    )
    
    post_high_4 = demo_user.posts.create!(
      title: '後輩への指導で感情的になり関係が悪化',
      content: '新人の後輩が同じミスを3回繰り返したため、つい感情的に叱ってしまった。その後、後輩は自分を避けるようになり、チームの雰囲気も悪くなった。1週間後、後輩から「もう少し優しく教えてほしい」と上司経由でフィードバックがあり、自分の指導方法の未熟さを痛感した。',
      cause: '感情的になった原因を内省。①自分自身の余裕のなさ：当時、複数のプロジェクトを抱えており、精神的に余裕がなかった。そのため、後輩のミスに対して「またか」という苛立ちが先に立った。②指導スキルの不足：「なぜミスが繰り返されるのか」を分析せず、表面的な注意だけで済ませていた。後輩の理解度や困っている点を確認するコミュニケーションが欠けていた。③完璧主義的な価値観：自分が新人時代に「ミスは絶対にしてはいけない」と教わった経験から、ミスに対して過度に厳しくなっていた。しかし、人は失敗から学ぶものであり、自分の価値観を押し付けていたことに気づいた。④心理的安全性の欠如：後輩が「わからない」と言いづらい雰囲気を作っていた可能性がある。',
      solution: '指導方法を根本から見直す。①感情管理：イライラしたら5秒深呼吸してから話す。また、自分の余裕がない時は「今は時間がないから、後で一緒に考えよう」と正直に伝える。②1on1の実施：週1回15分、後輩と1on1を設定。業務の困りごとや理解度を確認し、ミスの根本原因を一緒に探る。③ポジティブフィードバックの習慣化：注意3回に対して、褒めることを7回。良い点を積極的に伝え、信頼関係を構築する。④ミスを責めず、仕組みで防ぐ：「なぜミスが起きたか」を一緒に分析し、チェックリストやダブルチェック体制など、再発防止の仕組みを作る。⑤自分自身のメンタル管理：過労を防ぐため、タスクの優先順位を明確にし、必要なら上司に相談して負荷を調整。⑥後輩に謝罪：率直に「感情的になってごめん。今後は一緒に成長したい」と伝え、関係修復に努める。',
      learning: 'この失敗から、リーダーシップの本質を学んだ。①指導とは「教えること」ではなく「相手の成長を支援すること」。一方的な指示ではなく、相手の視点に立つことが重要。②感情のコントロールは、リーダーの必須スキル。自分の感情を相手にぶつけることは、信頼関係を破壊する。③心理的安全性の重要性：ミスを責める文化ではなく、ミスを共有して改善する文化を作ることが、チーム全体の成長につながる。④自分の価値観を疑う姿勢：「自分が正しい」と思い込まず、相手の状況や背景を理解しようとする謙虚さが必要。この経験は、今後マネジメントの立場になった時に必ず活きる。失敗を通じて、人間的に成長できたと感じている。',
      category: relationship,
      occurred_at: 12.days.ago
    )
    
    # 中程度のスコアの投稿も追加
    post_mid_1 = demo_user.posts.create!(
      title: '会議の時間管理ができず、残業が増えた',
      content: '週次の定例会議が毎回1時間の予定を30分オーバーしてしまう。結果として、午後の作業時間が圧迫され、残業が増加している。',
      cause: '議題が多すぎることと、話が脱線しやすいこと。また、タイムキーパーがいないため、時間配分が曖昧になっている。事前に資料を共有していないため、会議中に初見の内容を説明する時間が長い。',
      solution: '①会議の前日までに資料を共有し、事前に目を通してもらう。②アジェンダに各議題の時間配分を明記する（例：議題A 15分、議題B 20分）。③タイムキーパーを持ち回りで担当する。④決定事項と次のアクションを明確にし、議論が脱線したら軌道修正する。',
      learning: '会議は時間をかければ良いものではなく、効率が重要。事前準備と時間管理の意識が、チーム全体の生産性を左右する。',
      category: work,
      occurred_at: 8.days.ago
    )
    
    puts "✅ デモ投稿を作成しました（合計: #{demo_user.posts.count}件）"
    puts ""
    
    # AI評価を自動生成
    puts "🤖 AI評価を生成中..."
    
    # 低スコア投稿のAI評価
    [post_low_1, post_low_2, post_low_3].each do |post|
      post.create_ai_score!(
        cause_analysis_score: [10, 11, 12].sample,
        solution_specificity_score: [11, 12, 13].sample,
        learning_articulation_score: [12, 13, 14].sample,
        prevention_awareness_score: [10, 11, 12].sample,
        total_score: [48, 50, 52, 54].sample,
        feedback_comment: '原因分析や対策がやや抽象的です。「なぜ」を繰り返し深掘りすることで、より本質的な原因が見えてきます。また、対策は「いつ」「誰が」「何を」という具体性を持たせることで、実行可能性が高まります。',
        suggested_category: post.category.name,
        model_version: 'gpt-4-turbo',
        tokens_used: 850
      )
      post.update!(ai_evaluated: true, ai_evaluated_at: post.created_at + 5.minutes)
    end
    
    # 高スコア投稿のAI評価
    post_high_1.create_ai_score!(
      cause_analysis_score: 24,
      solution_specificity_score: 23,
      learning_articulation_score: 24,
      prevention_awareness_score: 23,
      total_score: 94,
      feedback_comment: '素晴らしい内省です！根本原因を技術・心理・組織の3つの観点から多角的に分析できています。また、再発防止策が極めて具体的で実行可能性が高いです。この失敗から得た「顧客影響を最小化する」という学びは、今後のキャリアで必ず活きるでしょう。',
      suggested_category: '仕事',
      model_version: 'gpt-4-turbo',
      tokens_used: 1200
    )
    post_high_1.update!(ai_evaluated: true, ai_evaluated_at: post_high_1.created_at + 5.minutes)
    
    post_high_2.create_ai_score!(
      cause_analysis_score: 23,
      solution_specificity_score: 24,
      learning_articulation_score: 23,
      prevention_awareness_score: 22,
      total_score: 92,
      feedback_comment: '5回のWhy分析により、表面的な原因から本質的な問題まで到達できています。短期・中期・長期の対策設計も実践的です。「ツールの目的理解」という学びは、他の場面にも応用できる普遍的な教訓ですね。',
      suggested_category: '仕事',
      model_version: 'gpt-4-turbo',
      tokens_used: 1150
    )
    post_high_2.update!(ai_evaluated: true, ai_evaluated_at: post_high_2.created_at + 5.minutes)
    
    post_high_3.create_ai_score!(
      cause_analysis_score: 22,
      solution_specificity_score: 24,
      learning_articulation_score: 23,
      prevention_awareness_score: 23,
      total_score: 92,
      feedback_comment: '学習方法の選択ミスを多角的に分析し、次回に向けた具体的な改善計画を立てられています。「インプット3割：アウトプット7割」という明確な指針や、進捗の可視化など、実行可能性の高い対策です。この失敗を次の成功につなげる姿勢が素晴らしいです。',
      suggested_category: '勉強',
      model_version: 'gpt-4-turbo',
      tokens_used: 1180
    )
    post_high_3.update!(ai_evaluated: true, ai_evaluated_at: post_high_3.created_at + 5.minutes)
    
    post_high_4.create_ai_score!(
      cause_analysis_score: 23,
      solution_specificity_score: 23,
      learning_articulation_score: 24,
      prevention_awareness_score: 22,
      total_score: 92,
      feedback_comment: '自己の感情や価値観まで内省できており、深い自己理解が見られます。指導方法の改善策が具体的で、特に「心理的安全性」の重要性に気づいている点が優秀です。この経験は、今後のリーダーシップに必ず活きる貴重な学びですね。',
      suggested_category: '人間関係',
      model_version: 'gpt-4-turbo',
      tokens_used: 1160
    )
    post_high_4.update!(ai_evaluated: true, ai_evaluated_at: post_high_4.created_at + 5.minutes)
    
    # 中程度投稿のAI評価
    post_mid_1.create_ai_score!(
      cause_analysis_score: 17,
      solution_specificity_score: 18,
      learning_articulation_score: 17,
      prevention_awareness_score: 16,
      total_score: 68,
      feedback_comment: '原因と対策を適切に分析できています。会議の効率化という具体的なアクションプランが良いですね。さらに良くするには、「なぜ事前資料を共有していなかったのか」など、もう一段深い原因分析ができると、より本質的な改善につながるでしょう。',
      suggested_category: '仕事',
      model_version: 'gpt-4-turbo',
      tokens_used: 950
    )
    post_mid_1.update!(ai_evaluated: true, ai_evaluated_at: post_mid_1.created_at + 5.minutes)
    
    puts "✅ AI評価を生成しました"
    puts ""
    
    # リマインダーの作成
    puts "📅 リマインダーを作成中..."
    demo_user.posts.each do |post|
      post.create_reminders!
    end
    puts "✅ リマインダーを作成しました"
    puts ""
    
    # 統計情報の表示
    puts "=" * 60
    puts "📊 デモデータの統計"
    puts "=" * 60
    puts "総投稿数: #{demo_user.posts.count}件"
    puts ""
    puts "【スコア分布】"
    puts "  50点以下（Eランク）: #{demo_user.posts.joins(:ai_score).where('ai_scores.total_score <= 50').count}件"
    puts "  51-59点（Dランク）: #{demo_user.posts.joins(:ai_score).where('ai_scores.total_score BETWEEN 51 AND 59').count}件"
    puts "  60-69点（Cランク）: #{demo_user.posts.joins(:ai_score).where('ai_scores.total_score BETWEEN 60 AND 69').count}件"
    puts "  70-79点（Bランク）: #{demo_user.posts.joins(:ai_score).where('ai_scores.total_score BETWEEN 70 AND 79').count}件"
    puts "  80-89点（Aランク）: #{demo_user.posts.joins(:ai_score).where('ai_scores.total_score BETWEEN 80 AND 89').count}件"
    puts "  90-100点（Sランク）: #{demo_user.posts.joins(:ai_score).where('ai_scores.total_score >= 90').count}件"
    puts ""
    puts "平均スコア: #{demo_user.posts.joins(:ai_score).average('ai_scores.total_score').round(1)}点"
    puts ""
    puts "【カテゴリ分布】"
    Category.all.each do |category|
      count = demo_user.posts.where(category: category).count
      puts "  #{category.name}: #{count}件" if count > 0
    end
    puts ""
    puts "=" * 60
    puts "🎉 デモデータのセットアップが完了しました！"
    puts "=" * 60
    puts ""
    puts "📝 ログイン情報"
    puts "   Email: demo@remind.com"
    puts "   Password: demo1234"
    puts ""
    puts "💡 プレゼン後にデモデータを削除するには："
    puts "   rails demo:cleanup"
    puts ""
  end
  
  desc "デモ用のデータを削除"
  task cleanup: :environment do
    puts "🗑️  デモデータの削除を開始します..."
    puts "=" * 60
    
    demo_user = User.find_by(email: 'demo@remind.com')
    
    if demo_user
      post_count = demo_user.posts.count
      demo_user.destroy
      
      puts "✅ デモユーザーと関連データを削除しました"
      puts "   削除した投稿数: #{post_count}件"
      puts ""
      puts "🎉 デモデータの削除が完了しました！"
    else
      puts "⚠️  デモユーザーが見つかりませんでした"
    end
    
    puts "=" * 60
  end
  
  desc "デモユーザーのログイン情報を表示"
  task info: :environment do
    demo_user = User.find_by(email: 'demo@remind.com')
    
    if demo_user
      puts "=" * 60
      puts "📝 デモユーザーのログイン情報"
      puts "=" * 60
      puts "Email: demo@remind.com"
      puts "Password: demo1234"
      puts ""
      puts "投稿数: #{demo_user.posts.count}件"
      if demo_user.posts.any?
        puts "平均スコア: #{demo_user.posts.joins(:ai_score).average('ai_scores.total_score')&.round(1)}点"
      end
      puts "=" * 60
    else
      puts "⚠️  デモユーザーが見つかりません"
      puts "作成するには: rails demo:setup"
    end
  end
end

