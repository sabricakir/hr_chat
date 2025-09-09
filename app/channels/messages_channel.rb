class MessagesChannel < ApplicationCable::Channel
  def subscribed
    chat_id = params[:chat_id]
    stream_from chat_id
  end

  def unsubscribed
  end
end
