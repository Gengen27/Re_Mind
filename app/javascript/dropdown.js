// ドロップダウンメニューの制御（Vanilla JavaScript）

// 初期化済みかどうかを追跡
let isInitialized = false;

function initDropdowns() {
  console.log('ドロップダウン初期化開始');
  
  const dropdownButton = document.querySelector('.dropdown-button');
  const dropdownMenu = document.querySelector('.dropdown-menu');
  const dropdown = document.querySelector('.dropdown');
  
  if (!dropdownButton || !dropdownMenu || !dropdown) {
    console.log('ドロップダウン要素が見つかりません');
    return;
  }
  
  console.log('ドロップダウン要素を検出しました');
  
  // 既存のリスナーをクリア（重複防止）
  const newButton = dropdownButton.cloneNode(true);
  dropdownButton.parentNode.replaceChild(newButton, dropdownButton);
  
  // ボタンクリックでメニュー開閉
  newButton.addEventListener('click', function(e) {
    e.preventDefault();
    e.stopPropagation();
    console.log('ドロップダウンボタンがクリックされました');
    dropdownMenu.classList.toggle('show');
    console.log('メニュー状態:', dropdownMenu.classList.contains('show') ? '表示' : '非表示');
  });
  
  // 外側クリックで閉じる（既存のリスナーを削除してから追加）
  if (!isInitialized) {
    document.addEventListener('click', function(e) {
      if (dropdown && !dropdown.contains(e.target)) {
        if (dropdownMenu.classList.contains('show')) {
          console.log('外側クリック: メニューを閉じます');
          dropdownMenu.classList.remove('show');
        }
      }
    });
    isInitialized = true;
  }
  
  console.log('ドロップダウン初期化完了');
}

// DOMContentLoaded
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initDropdowns);
} else {
  initDropdowns();
}

// Turbo対応
document.addEventListener('turbo:load', initDropdowns);
document.addEventListener('turbo:render', initDropdowns);