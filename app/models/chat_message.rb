class ChatMessage < ApplicationRecord
  enum role: { user: 0, bot: 1 }, _prefix: true
  enum status: { past: 0, placeholder: 1, completed: 2 }

  validates :role, presence: true
  validates :content, presence: true

  scope :for_chat, -> (chat_id) { where(chat_id: chat_id).order(:created_at) }

  has_one :feedback, class_name: "ChatFeedback", dependent: :destroy

  def feedback_given?
    feedback.present?
  end
end
