import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "searchInput",
    "hierarchyContainer",
    "searchContainer",
    "usersList",
    "teamsList",
    "companiesList"
  ]

  connect() {
    this.filter()
  }

  filter() {
    const query = this.searchInputTarget.value.trim().toLowerCase()

    if (query.length === 0) {
      this.hierarchyContainerTarget.classList.remove("hidden")
      this.searchContainerTarget.classList.add("hidden")
      return
    }

    this.hierarchyContainerTarget.classList.add("hidden")
    this.searchContainerTarget.classList.remove("hidden")

    if (this.hasUsersListTarget) {
      this.#filterList(this.usersListTarget, query)
    }
    if (this.hasTeamsListTarget) {
      this.#filterList(this.teamsListTarget, query)
    }
    if (this.hasCompaniesListTarget) {
      this.#filterList(this.companiesListTarget, query)
    }
  }

  #filterList(listElement, query) {
    const items = listElement.querySelectorAll("li")
    items.forEach(li => {
      const name = (li.dataset.name || "").toLowerCase()
      if (name.includes(query)) {
        li.classList.remove("hidden")
      } else {
        li.classList.add("hidden")
      }
    })
  }
}
