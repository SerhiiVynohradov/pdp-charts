import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "nameInput",
    "results",
    "recommendedItemId",
    "recommendedItemsPath",
    "resetButton"
  ]

  connect() {
    // ...
  }

  // 1) Поиск
  search() {
    const query = this.nameInputTarget.value.trim()
    if (query.length < 2) {
      this.resultsTarget.innerHTML = ""
      this.resultsTarget.classList.add("hidden")
      return
    }

    // Получаем путь (возможно уже с ?locale=xxx)
    const path = this.recommendedItemsPathTarget.value

    // Если в path уже есть хотя бы один параметр, добавляем "&search=", иначе "?search="
    const separator = path.includes("?") ? "&" : "?"

    fetch(`${path}${separator}search=${encodeURIComponent(query)}`, {
      headers: { "Accept": "application/json" }
    })
      .then(r => r.json())
      .then(data => this.showResults(data))
  }

  // 2) Отрисовка результатов
  showResults(items) {
    this.resultsTarget.innerHTML = ""

    if (!items || items.length === 0) {
      const li = document.createElement("li")
      li.className = "px-4 py-2 text-sm text-gray-400"
      li.textContent = "No results"
      this.resultsTarget.appendChild(li)
      this.resultsTarget.classList.remove("hidden")
      return
    }

    items.forEach(item => {
      const li = document.createElement("li")
      li.className = "block w-full text-left text-sm text-gray-200 " +
                     "px-4 py-2 hover:bg-gray-700 hover:text-white " +
                     "cursor-pointer border-b border-gray-700 last:border-0"

      li.innerHTML = `
        <div class="flex justify-between">
          <span class="font-bold text-white">${item.name}</span>
          <span class="text-sm text-gray-400">(Effort: ${item.effort})</span>
        </div>
        <hr class="border-gray-600 my-1">
        <div class="text-xs text-gray-400">
          ${item.description || ""}
        </div>
      `
      li.addEventListener("click", () => this.selectItem(item))
      this.resultsTarget.appendChild(li)
    })

    this.resultsTarget.classList.remove("hidden")
  }

  // 3) Выбор результата
  selectItem(item) {
    // (a) Запоминаем ID
    this.recommendedItemIdTarget.value = item.id

    // (b) Подставляем в Name, дизейблим
    this.nameInputTarget.value = item.name
    this.nameInputTarget.disabled = true

    // (c) Category
    const categoryHidden  = document.getElementById("categoryHiddenField")
    const categoryBtn     = document.getElementById("categoryDropdownButton")
    const categoryText    = document.getElementById("categoryDropdownText")
    if (categoryHidden && categoryBtn && categoryText) {
      if (item.category_id) {
        categoryHidden.value = item.category_id
        categoryText.innerText = item.category_name || "Selected from recommended"
      }
      // Дизейблим кнопку (чтобы не меняли)
      categoryBtn.disabled = true
      // Можно ещё визуально «затемнить», например:
      categoryBtn.classList.add("opacity-50", "cursor-not-allowed")
    }

    // (d) Effort
    const effortHidden  = document.getElementById("effortHiddenField")
    const effortBtn     = document.getElementById("effortDropdownButton")
    const effortText    = document.getElementById("effortDropdownText")
    if (effortHidden && effortBtn && effortText) {
      if (item.effort) {
        effortHidden.value = item.effort
        // mapping (to_s -> change to these strings):
        // 1 = Very Easy (1 point)
        // 2 = Easy (2 points)
        // 3 = Medium  (3 points)
        // 4 = Hard (4 points)
        // 5 = Very Hard (5 points)
        switch (item.effort.toString()) {
          case "1":
            effortText.innerText = "Effort: Very Easy (1 point)"
            break
          case "2":
            effortText.innerText = "Effort: Easy (2 points)"
            break
          case "3":
            effortText.innerText = "Effort: Medium (3 points)"
            break
          case "4":
            effortText.innerText = "Effort: Hard (4 points)"
            break
          case "5":
            effortText.innerText = "Effort: Very Hard (5 points)"
            break
          default:
            effortText.innerText = "Select Effort"
        }
      }
      // Дизейблим
      effortBtn.disabled = true
      effortBtn.classList.add("opacity-50", "cursor-not-allowed")
    }

    // (e) Скрываем выпадающий список
    this.resultsTarget.classList.add("hidden")

    // (f) Показываем кнопку "X"
    this.resetButtonTarget.classList.remove("hidden")
  }

  // 4) Сброс выбора
  resetSelection() {
    // (a) Чистим ID
    this.recommendedItemIdTarget.value = ""

    // (b) Разблок Name
    this.nameInputTarget.disabled = false
    this.nameInputTarget.value = ""

    // (c) Category
    const categoryHidden  = document.getElementById("categoryHiddenField")
    const categoryBtn     = document.getElementById("categoryDropdownButton")
    const categoryText    = document.getElementById("categoryDropdownText")
    if (categoryHidden && categoryBtn && categoryText) {
      categoryHidden.value = ""
      categoryText.innerText = "Select Category"
      categoryBtn.disabled = false
      categoryBtn.classList.remove("opacity-50", "cursor-not-allowed")
    }

    // (d) Effort
    const effortHidden  = document.getElementById("effortHiddenField")
    const effortBtn     = document.getElementById("effortDropdownButton")
    const effortText    = document.getElementById("effortDropdownText")
    if (effortHidden && effortBtn && effortText) {
      effortHidden.value = ""
      effortText.innerText = "Select Effort"
      effortBtn.disabled = false
      effortBtn.classList.remove("opacity-50", "cursor-not-allowed")
    }

    // (e) Скрываем кнопку "X"
    this.resetButtonTarget.classList.add("hidden")
  }
}
