import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["trigger"]

  closeOutside(event) {
    if (!this.element.contains(event.target)) this.close()
  }

  closeAndFocus() {
    if (!this.element.open) return

    this.close()
    this.triggerTarget.focus()
  }

  close() {
    this.element.open = false
  }
}
