import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display", "form"]

  toggleEdit(event) {
    event.preventDefault()
    // show/hide the relevant elements
    this.displayTarget.classList.toggle("hidden")
    this.formTarget.classList.toggle("hidden")
  }

  submit(event) {
    event.preventDefault()

    const form = event.currentTarget
    const url = form.action
    const method = form.method.toUpperCase() // typically PATCH
    const formData = new FormData(form)

    fetch(url, {
      method: method,
      headers: {
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
      },
      body: formData
    })
      .then(resp => resp.text())
      .then(html => {
        // Replace the entire row's <turbo-frame> or <tr> in the DOM with the updated content
        this.element.outerHTML = html
      })
      .catch(err => console.error("Inline edit error:", err))
  }
}
