class CreateReflectionItems < ActiveRecord::Migration[7.1]
  def change
    create_table :reflection_items do |t|
      t.references :reminder, null: false, foreign_key: true
      t.references :post, null: false, foreign_key: true
      
      t.text :content, null: false # チェック項目の内容
      t.string :item_type # 'memory', 'awareness', 'growth'（記憶系、意識系、成長実感系）
      t.integer :position, default: 0, null: false # 表示順序
      
      t.boolean :checked, default: false, null: false # チェック済みかどうか
      t.datetime :checked_at # チェックした日時
      
      t.boolean :ai_generated, default: true, null: false # AIが生成したか、ユーザーが追加したか

      t.timestamps
    end

    add_index :reflection_items, [:reminder_id, :position]
    add_index :reflection_items, :checked
  end
end

