import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["viewMode", "editMode"]

  connect() {
    // Можно сразу что-то инициализировать, если нужно
  }

  enableEdit(event) {
    event.preventDefault()
    this.viewModeTarget.classList.add("hidden")
    this.editModeTarget.classList.remove("hidden")
  }

  disableEdit(event) {
    event.preventDefault()
    this.editModeTarget.classList.add("hidden")
    this.viewModeTarget.classList.remove("hidden")
  }
}
