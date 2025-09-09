import consumer from "channels/consumer"

const messagesContainer = document.getElementById("messages")
const chatId = messagesContainer?.dataset.chatId

consumer.subscriptions.create(
  { channel: "MessagesChannel", chat_id: chatId },
  {
    connected() {
      console.log("Connected to MessagesChannel:", chatId)
    },

    disconnected() {
      console.log("Disconnected from MessagesChannel:", chatId)
    },

    received(data) {
      if (messagesContainer) {
        Turbo.renderStreamMessage(data)
        messagesContainer.scrollTop = messagesContainer.scrollHeight
      }
    }
  }
)
