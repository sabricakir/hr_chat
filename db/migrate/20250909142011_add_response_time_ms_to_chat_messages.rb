class AddResponseTimeMsToChatMessages < ActiveRecord::Migration[7.1]
  def change
    add_column :chat_messages, :response_time_ms, :integer
  end
end
