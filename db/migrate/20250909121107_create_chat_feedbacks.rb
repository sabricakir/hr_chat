class CreateChatFeedbacks < ActiveRecord::Migration[7.1]
  def change
    create_table :chat_feedbacks do |t|
      t.string :chat_id
      t.references :chat_message, null: false, foreign_key: true   # <-- ilişki için eklendi
      t.boolean :liked
      t.string :llm_model
      t.string :embedding_model
      t.integer :chunk_size
      t.integer :overlap
      t.integer :limit
      t.integer :top_chunks

      t.timestamps
    end
  end
end
