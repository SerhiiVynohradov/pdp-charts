import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    url: String,          // e.g. /manager/teams/1/users/12/items/1
    fieldName: String,    // e.g. "name" or "email" or "percent"
    initialValue: String, // The old value for the input
    resourceName: String, // e.g. "user" or "item" or "progress_update"
    method: String        // "patch" или "post"
  }

  static targets = [
    "display",       // the <span> or display text
    "form",          // the hidden form
    "input",         // the actual <input> or <select>
    "linkPreventer"  // optional anchor we don't want to trigger edit
  ]

  connect() {
    this.setInputValue(this.initialValueValue || "")
  }

  enableEdit(event) {
    // If user clicked a link (linkPreventer), skip editing
    if (this.hasLinkPreventerTarget && event.target.closest("[data-cell-edit-target='linkPreventer']")) {
      return
    }

    // Already editing? Do nothing
    if (!this.formTarget.classList.contains("hidden")) return

    // Show form, hide display
    this.displayTarget.classList.add("hidden")
    this.formTarget.classList.remove("hidden")

    // Focus logic (avoid setSelectionRange on <select> or numeric <input>)
    if (this.inputTarget.tagName === "INPUT" && this.inputTarget.type === "text") {
      this.inputTarget.focus()
      const val = this.inputTarget.value
      this.inputTarget.setSelectionRange(val.length, val.length)
    } else {
      this.inputTarget.focus()
    }
  }

  async submit(event) {
    event.preventDefault()

    let newValue
    if (this.inputTarget.tagName === "SELECT") {
      newValue = this.inputTarget.value
    } else {
      newValue = this.inputTarget.value.trim()
    }

    const formData = new FormData()
    formData.append(`${this.resourceNameValue}[${this.fieldNameValue}]`, newValue)

    try {
      const response = await fetch(this.urlValue, {
        method: this.methodValue || "PATCH",
        headers: {
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
          "Accept": "application/json, text/vnd.turbo-stream.html"
        },
        body: formData
      })

      if (response.ok) {
        const contentType = response.headers.get("Content-Type")
        if (contentType.includes("text/vnd.turbo-stream.html")) {
          const turboStream = await response.text()
          Turbo.renderStreamMessage(turboStream)
        } else if (contentType.includes("application/json")) {
          const data = await response.json()
          const updatedRaw = data[this.fieldNameValue] ?? ""
          const displayString = this.computeDisplayValue(updatedRaw)

          // Update the <span> text
          this.displayTarget.textContent = displayString

          // Store new raw value for next time
          this.initialValueValue = updatedRaw
          this.setInputValue(updatedRaw)

          // Hide form, show display
          this.formTarget.classList.add("hidden")
          this.displayTarget.classList.remove("hidden")
        }
      } else {
        // Handle errors
        const errorData = await response.json()
        alert("Error: " + (errorData.errors ? errorData.errors.join(", ") : "Unknown error"))
      }
    } catch (error) {
      console.error("Inline edit error:", error)
      alert("An error occurred while updating.")
    }
  }

  // Optional "cancel" method
  cancelEdit(event) {
    event.preventDefault()
    this.setInputValue(this.initialValueValue || "")
    this.formTarget.classList.add("hidden")
    this.displayTarget.classList.remove("hidden")
  }

  setInputValue(raw) {
    if (!this.hasInputTarget) return

    if (this.inputTarget.tagName === "SELECT") {
      // For select, set .value to match an <option>
      this.inputTarget.value = raw
    } else {
      // For text/number
      this.inputTarget.value = raw
    }
  }

  computeDisplayValue(raw) {
    if (!raw) return "-"

    // Custom logic based on fieldName, если необходимо
    return raw
  }
}
