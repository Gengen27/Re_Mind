// フラッシュメッセージの自動非表示（Vanilla JavaScript）

class FlashMessage {
  constructor(element) {
    this.element = element
    this.autoHideDelay = 5000 // 5秒
    
    this.init()
  }

  init() {
    // 自動で消す
    setTimeout(() => {
      this.dismiss()
    }, this.autoHideDelay)

    // 閉じるボタンがあればイベント設定
    const closeButton = this.element.querySelector('.flash-close')
    if (closeButton) {
      closeButton.addEventListener('click', () => {
        this.dismiss()
      })
    }
  }

  dismiss() {
    this.element.style.animation = 'slideOut 0.3s ease-out'
    
    setTimeout(() => {
      this.element.remove()
    }, 300)
  }
}

// 初期化
function initFlashMessages() {
  const flashMessages = document.querySelectorAll('.flash')
  flashMessages.forEach(element => {
    new FlashMessage(element)
  })
}

document.addEventListener('DOMContentLoaded', initFlashMessages)
document.addEventListener('turbo:load', initFlashMessages)