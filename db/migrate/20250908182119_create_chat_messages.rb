class CreateChatMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :chat_messages do |t|
      t.integer :role, null: false
      t.text :content, null: false
      t.jsonb :sources, default: []
      t.jsonb :snippets, default: []
      t.string :chat_id

      t.timestamps
    end
  end
end
