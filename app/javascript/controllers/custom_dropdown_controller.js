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
      const optionEl = this.menuTarget.querySelector(`[data-value="${currentValue}"]`)
      if (optionEl && optionEl.dataset.label) {
        this.selectedTextTarget.textContent = optionEl.dataset.label
      }
    }
  }

  toggle(event) {
    event.preventDefault()
    this.menuTarget.classList.toggle("hidden")
  }

  select(event) {
    event.preventDefault()
    const optionEl = event.currentTarget
    const newValue = optionEl.dataset.value
    const newLabel = optionEl.dataset.label

    this.hiddenInputTarget.value = newValue
    this.selectedTextTarget.textContent = newLabel
    this.menuTarget.classList.add("hidden")
  }
}
