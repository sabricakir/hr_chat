import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { content: String }

  connect() {
    if (this.contentValue) this.typeWriter(this.contentValue)
  }

  typeWriter(text, speed = 30) {
    this.element.textContent = ""
    let i = 0
    const interval = setInterval(() => {
      this.element.textContent += text.charAt(i)
      i++

      const container = document.getElementById("messages")
      const messageBox = this.element.closest("div[id^='message_']")
      if (messageBox && container) {
        container.scrollTop = messageBox.offsetTop + messageBox.offsetHeight
      }
      if (i >= text.length) clearInterval(interval)
    }, speed)
  }
}
