import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display", "form"]

  toggleEdit(event) {
    event.preventDefault()
    // Hide display, show form
    this.displayTarget.classList.toggle("hidden")
    this.formTarget.classList.toggle("hidden")
  }

  submit(event) {
    // This is triggered by "submit->inline-edit#submit" in the form
    event.preventDefault()

    const form = event.currentTarget
    const url = form.action
    const formData = new FormData(form)

    fetch(url, {
      method: "PATCH",
      headers: {
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
      },
      body: formData
    })
      .then(response => response.text())
      .then(html => {
        // Replace the entire turbo-frame (the parent row)
        this.element.outerHTML = html
      })
      .catch(err => {
        console.error("Inline edit update failed:", err)
      })
  }
}
