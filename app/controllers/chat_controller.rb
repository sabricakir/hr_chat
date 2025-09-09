class ChatController < ApplicationController
  before_action :set_chat_id
  before_action :set_rag_settings

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

    answer_data = OllamaService.answer_with_context(
      user_message,
      llm_model: @selected_llm,
      embedding_model: @selected_embedding,
      chunk_size: @selected_chunk_size,
      overlap: @selected_overlap,
      limit: @selected_limit,
      top_chunks: @selected_top_chunks
    )

    placeholder.update!(
      content: answer_data[:answer],
      sources: answer_data[:sources],
      status: :completed
    )
    broadcast(placeholder, replace: true)

    placeholder.past!
  end

  def settings
    session[:llm_model]       = params[:llm_model]
    session[:embedding_model] = params[:embedding_model]
    session[:chunk_size]      = params[:chunk_size].presence&.to_i || 500
    session[:overlap]         = params[:overlap].presence&.to_i || 50
    session[:limit]           = params[:limit].presence&.to_i || 20
    session[:top_chunks]      = params[:top_chunks].presence&.to_i || 5

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.append(
          "notice",
          partial: "shared/notice",
          locals: { notice: "Ayarlar güncellendi.", flash_type: :notice }
        )
      end
      format.html { redirect_to chat_index_path, notice: "Ayarlar güncellendi." }
    end
  end

  def feedback
    msg = ChatMessage.find(params[:message_id])

    ChatFeedback.create!(
      chat_id: @chat_id,
      chat_message_id: msg.id,
      liked: params[:liked] == "true",
      llm_model: @selected_llm,
      embedding_model: @selected_embedding,
      chunk_size: @selected_chunk_size,
      overlap: @selected_overlap,
      limit: @selected_limit,
      top_chunks: @selected_top_chunks
    )

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove("feedback_#{msg.id}"),
          turbo_stream.append(
            "notice",
            partial: "shared/notice",
            locals: { notice: "Geri bildiriminiz için teşekkürler!", flash_type: :notice }
          )
        ]
      end
      format.html { redirect_to chat_index_path }
    end
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

  def set_rag_settings
    @llm_models = Rails.application.credentials.dig(:chat, :llm_models)
    @embedding_models = Rails.application.credentials.dig(:chat, :embedding_models)

    @selected_llm        = session[:llm_model]       || @llm_models.first
    @selected_embedding  = session[:embedding_model] || @embedding_models.first
    @selected_chunk_size = session[:chunk_size]      || 500
    @selected_overlap    = session[:overlap]         || 50
    @selected_limit      = session[:limit]           || 20
    @selected_top_chunks = session[:top_chunks]      || 5
  end
end
