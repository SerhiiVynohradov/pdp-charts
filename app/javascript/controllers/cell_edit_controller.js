import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    url: String,          // e.g. /my/items/1
    fieldName: String,    // e.g. "name" or "progress"
    initialValue: String  // The old value for the input
  }

  static targets = [
    "display",       // the <span> or display text
    "form",          // the hidden form
    "input",         // the actual <input> or <select>
    "linkPreventer"  // optional anchor we don't want to trigger edit
  ]

  connect() {
    // Load the old value into the input. Must match your data attribute.
    // If initialValue is blank, we do "" so the user sees an empty field.
    this.setInputValue(this.initialValueValue || "")
  }

  enableEdit(event) {
    // If user clicked a link (linkPreventer), skip editing
    if (this.hasLinkPreventerTarget && event.target.closest("[data-cell-edit-target='linkPreventer']")) {
      return
    }

    // Already editing? do nothing
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

  submit(event) {
    event.preventDefault()

    let newValue
    if (this.inputTarget.tagName === "SELECT") {
      newValue = this.inputTarget.value
    } else {
      newValue = this.inputTarget.value.trim()
    }

    const formData = new FormData()
    formData.append(`item[${this.fieldNameValue}]`, newValue)

    fetch(this.urlValue, {
      method: "PATCH",
      headers: {
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
        Accept: "application/json"
      },
      body: formData
    })
      .then(response => {
        if (!response.ok) {
          throw new Error(`Update failed with status ${response.status}`)
        }
        return response.json()
      })
      .then(data => {
        const updatedRaw = data[this.fieldNameValue] ?? ""
        // Convert raw to something display-friendly
        const displayString = this.computeDisplayValue(updatedRaw)

        // Update the <span> text
        this.displayTarget.textContent = displayString

        // Store new raw value for next time
        this.initialValueValue = updatedRaw
        this.setInputValue(updatedRaw)

        // Hide form, show display
        this.formTarget.classList.add("hidden")
        this.displayTarget.classList.remove("hidden")
      })
      .catch(err => console.error("Inline edit error:", err))
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

    if (this.fieldNameValue === "progress") {
      return `${raw}%`
    }
    if (this.fieldNameValue === "effort") {
      return this.effortLabel(raw)
    }
    return raw
  }

  effortLabel(code) {
    switch (code) {
      case "5":
        return "5 - Very Hard (10+ full-time days)"
      case "4":
        return "4 - Hard (5-10 full-time days)"
      case "3":
        return "3 - Medium (3-5 full-time days)"
      case "2":
        return "2 - Easy (2-3 full-time days)"
      case "1":
        return "1 - Very Easy (<1 full-time day)"
      default:
        return "-"
    }
  }
}
