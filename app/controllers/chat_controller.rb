class ChatController < ApplicationController
  before_action :set_chat_id

  def index
    @messages = ChatMessage.for_chat(@chat_id)
  end

  def create
    user_message = params[:message]
    return if user_message.blank?

    user_msg = ChatMessage.create!(
      chat_id: @chat_id,
      role: :user,
      content: user_message
    )
    broadcast(user_msg)

    placeholder = ChatMessage.create!(
      chat_id: @chat_id,
      role: :bot,
      content: "🤔 düşünüyor...",
      status: :placeholder
    )
    broadcast(placeholder)

    answer_data = OllamaService.answer_with_context(user_message)
    placeholder.update!(
      content: answer_data[:answer],
      sources: answer_data[:sources],
      status: :completed
    )
    broadcast(placeholder, replace: true)

    placeholder.past!
  end

  private

  def set_chat_id
    @chat_id = session.id.to_s
  end

  def broadcast(msg, replace: false)
    method = replace ? :broadcast_replace_to : :broadcast_append_to
    Turbo::StreamsChannel.public_send(
      method,
      @chat_id,
      target: replace ? "message_#{msg.id}" : "messages",
      partial: "chat/message",
      locals: { msg: msg }
    )
  end
end
