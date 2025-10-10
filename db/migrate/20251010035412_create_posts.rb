class CreatePosts < ActiveRecord::Migration[7.1]
  def change
    create_table :posts do |t|
      t.references :user, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      
      t.string :title, null: false
      t.text :content, null: false
      t.text :cause # 原因
      t.text :solution # 対策
      t.text :learning # 学び
      t.date :occurred_at # 失敗発生日
      
      t.boolean :ai_evaluated, default: false
      t.datetime :ai_evaluated_at

      t.timestamps
    end

    add_index :posts, :created_at
    add_index :posts, :occurred_at
  end
end

