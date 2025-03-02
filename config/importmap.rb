# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "tailwind-scrollbar" # @4.0.1
pin "tailwindcss/lib/util/flattenColorPalette", to: "tailwindcss--lib--util--flattenColorPalette.js" # @4.0.9
pin "tailwindcss/plugin", to: "tailwindcss--plugin.js" # @4.0.9
