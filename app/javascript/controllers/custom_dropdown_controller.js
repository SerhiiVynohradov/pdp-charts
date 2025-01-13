import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "button",
    "menu",
    "selectedText",
    "hiddenInput"
  ]

  connect() {
    const currentValue = this.hiddenInputTarget.value
    if (currentValue) {
      this.selectedTextTarget.textContent = this.mapValueToLabel(currentValue)
    }
  }

  toggle(event) {
    event.preventDefault()
    this.menuTarget.classList.toggle("hidden")
  }

  select(event) {
    event.preventDefault()
    const newValue  = event.currentTarget.dataset.value
    const newLabel = this.mapValueToLabel(event.currentTarget.dataset.value)

    this.hiddenInputTarget.value = newValue
    this.selectedTextTarget.textContent = newLabel
    this.menuTarget.classList.add("hidden")
  }

  mapValueToLabel(value) {
    switch (value) {
      case "5": return "Very Hard (5 points)"
      case "4": return "Hard (4 points)"
      case "3": return "Medium (3 points)"
      case "2": return "Easy (2 points)"
      case "1": return "Very Easy (1 point)"
      default:  return "Select Effort"
    }
  }
}
