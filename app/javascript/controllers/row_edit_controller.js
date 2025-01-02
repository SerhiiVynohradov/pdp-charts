import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["displayRow", "editRow", "form"]

  toggleEdit(event) {
    event.preventDefault()
    this.displayRowTarget.classList.add("hidden")
    this.editRowTarget.classList.remove("hidden")
  }

  submit(event) {
    event.preventDefault()
    const form = this.formTarget
    const url = form.action
    const method = form.method.toUpperCase()

    fetch(url, {
      method: method,
      headers: {
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
      },
      body: new FormData(form)
    })
      .then(resp => resp.text())
      .then(html => {
        this.element.outerHTML = html
      })
      .catch(err => console.error("inline-edit error:", err))
  }
}
