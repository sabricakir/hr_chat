class AddStatusToChatMessages < ActiveRecord::Migration[7.1]
  def change
    add_column :chat_messages, :status, :integer, default: 0, null: false
  end
end
