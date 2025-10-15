# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js"

# Vanilla JavaScript modules
pin "dropdown", to: "dropdown.js"
pin "flash", to: "flash.js"
pin "chart", to: "chart.js"
