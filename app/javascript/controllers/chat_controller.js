import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["messages", "input"]

  connect() {
    this.scrollToBottom()
  }

  scrollToBottom() {
    if (this.hasMessagesTarget) {
      this.messagesTarget.scrollTo({
        top: this.messagesTarget.scrollHeight,
        behavior: "smooth"
      })
    }
  }

  scrollOnAppend() {
    setTimeout(() => this.scrollToBottom(), 50)
  }

  clearInput() {
    if (this.hasInputTarget) {
      this.inputTarget.value = ""
      this.scrollToBottom()
    }
  }

  autoScrollOnTyping() {
    this.scrollToBottom()
  }

  lockInput() {
    if (this.hasInputTarget) {
      this.inputTarget.value = ""
      this.inputTarget.readOnly = true
    }
  }

  unlockInput() {
    if (this.hasInputTarget) {
      this.inputTarget.readOnly = false
      this.inputTarget.focus()
      this.scrollToBottom()
    }
  }
}
