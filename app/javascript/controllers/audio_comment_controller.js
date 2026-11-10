import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["audio", "seconds", "display", "clearButton"]

  connect() {
    this.revealFromAnchor()
  }

  revealFromAnchor() {
    if (window.location.hash !== `#${this.element.id}`) return

    this.element.open = true
    this.element.scrollIntoView({ block: "start" })
  }

  captureTime() {
    const seconds = Math.floor(this.audioTarget.currentTime)
    const minutes = Math.floor(seconds / 60)
    const remainder = seconds % 60

    this.secondsTarget.value = seconds
    this.displayTarget.textContent = `${String(minutes).padStart(2, "0")}:${String(remainder).padStart(2, "0")}`
    this.clearButtonTarget.hidden = false
  }

  clearTime() {
    this.secondsTarget.value = ""
    this.displayTarget.textContent = "未設定"
    this.clearButtonTarget.hidden = true
  }

  seekTo(event) {
    const seconds = Number(event.currentTarget.dataset.seconds)
    if (!Number.isFinite(seconds) || seconds < 0) return

    this.audioTarget.currentTime = seconds
    this.audioTarget.play().catch(() => {
      // The native controls remain available if the browser rejects playback.
    })
  }

  pauseWhenClosed() {
    if (!this.element.open && this.hasAudioTarget) this.audioTarget.pause()
  }

  pauseOtherVersions() {
    this.element.closest(".project-layout").querySelectorAll("audio").forEach(audio => {
      if (audio !== this.audioTarget) audio.pause()
    })
  }
}
