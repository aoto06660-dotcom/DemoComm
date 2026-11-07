import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["audio", "seconds", "display"]

  captureTime() {
    const currentTime = this.audioTarget.currentTime
    const seconds = Math.floor(currentTime)

    this.secondsTarget.value = seconds

    const minutes = Math.floor(seconds / 60)
    const remainSeconds = seconds % 60

    const formattedTime = 
      `${String(minutes).padStart(2, "0")}:${String(remainSeconds).padStart(2, "0")}`

    this.displayTarget.textContent = formattedTime
  }

  seekTo(event) {
    const seconds = Number(event.currentTarget.dataset.seconds)

    if (!Number.isFinite(seconds) || seconds < 0) {
      return
    }

    this.audioTarget.currentTime = seconds
    this.audioTarget.play()
  }
}