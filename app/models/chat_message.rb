class ChatMessage < ApplicationRecord
  enum role: { user: 0, bot: 1 }
  validates :role, presence: true
  validates :content, presence: true

  scope :for_chat, -> (chat_id) { where(chat_id: chat_id).order(:created_at) }
end
