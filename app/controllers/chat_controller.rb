class ChatController < ApplicationController
  before_action :set_chat_id

  def index
    @messages = ChatMessage.for_chat(@chat_id)
  end

  def create
    user_message = params[:message]
    return if user_message.blank?

    # answer_data = OllamaService.answer_with_context(user_message)

    answer_data = {
      answer: "Bu bir yanıt.",
      sources: ["source1", "source2"],
      snippets: ["snippet1", "snippet2"]
    }

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.append(
            "messages",
            partial: "chat/message",
            locals: { msg: ChatMessage.create!(
              chat_id: @chat_id,
              role: :user,
              content: user_message
              )
            }
          ),
          turbo_stream.append(
            "messages",
            partial: "chat/message",
            locals: {
              msg: ChatMessage.create!(
                chat_id: @chat_id,
                role: :bot,
                content: answer_data[:answer],
                sources: answer_data[:sources]
              )
            }
          )
        ]
      end

      format.html { redirect_to root_path }
    end
  end

  private

  def set_chat_id
    @chat_id = session.id.to_s
  end
end
