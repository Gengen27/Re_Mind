// ドロップダウンメニューの制御（Vanilla JavaScript）

class Dropdown {
  constructor(element) {
    this.element = element
    this.button = element.querySelector('.dropdown-button')
    this.menu = element.querySelector('.dropdown-menu')
    
    this.init()
  }

  init() {
    if (!this.button || !this.menu) return
    
    // ボタンクリックでメニュー開閉
    this.button.addEventListener('click', (e) => {
      e.preventDefault()
      e.stopPropagation()
      this.toggle()
    })

    // 外側クリックで閉じる
    document.addEventListener('click', (e) => {
      if (!this.element.contains(e.target)) {
        this.close()
      }
    })
  }

  toggle() {
    this.menu.classList.toggle('show')
  }

  close() {
    this.menu.classList.remove('show')
  }

  open() {
    this.menu.classList.add('show')
  }
}

// 初期化
document.addEventListener('DOMContentLoaded', () => {
  const dropdowns = document.querySelectorAll('.dropdown')
  dropdowns.forEach(element => {
    new Dropdown(element)
  })
})

// Turbo対応（ページ遷移後も動作）
document.addEventListener('turbo:load', () => {
  const dropdowns = document.querySelectorAll('.dropdown')
  dropdowns.forEach(element => {
    new Dropdown(element)
  })
})