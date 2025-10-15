// グラフ表示（Vanilla JavaScript + Chart.js）

class ChartRenderer {
  constructor(canvas) {
    this.canvas = canvas
    this.chartType = canvas.dataset.chartType
    this.dataUrl = canvas.dataset.chartUrl
    
    this.init()
  }

  async init() {
    try {
      const data = await this.fetchData()
      this.renderChart(data)
    } catch (error) {
      console.error('Chart loading error:', error)
      this.showError()
    }
  }

  async fetchData() {
    const response = await fetch(this.dataUrl)
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`)
    }
    return await response.json()
  }

  renderChart(data) {
    const ctx = this.canvas.getContext('2d')
    
    switch (this.chartType) {
      case 'line':
        this.renderLineChart(ctx, data)
        break
      case 'bar':
        this.renderBarChart(ctx, data)
        break
      case 'radar':
        this.renderRadarChart(ctx, data)
        break
      default:
        console.error('Unknown chart type:', this.chartType)
    }
  }

  renderLineChart(ctx, data) {
    new Chart(ctx, {
      type: 'line',
      data: {
        labels: data.labels,
        datasets: [{
          label: 'スコア',
          data: data.scores,
          borderColor: '#4F46E5',
          backgroundColor: 'rgba(79, 70, 229, 0.1)',
          tension: 0.4,
          fill: true,
          pointRadius: 5,
          pointHoverRadius: 7
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            display: false
          },
          tooltip: {
            callbacks: {
              label: function(context) {
                return 'スコア: ' + context.parsed.y + '点'
              }
            }
          }
        },
        scales: {
          y: {
            beginAtZero: true,
            max: 100,
            ticks: {
              callback: function(value) {
                return value + '点'
              }
            }
          }
        }
      }
    })
  }

  renderBarChart(ctx, data) {
    new Chart(ctx, {
      type: 'bar',
      data: {
        labels: data.category_data.labels,
        datasets: [{
          label: '平均スコア',
          data: data.category_data.scores,
          backgroundColor: data.category_data.colors,
          borderRadius: 8
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            display: false
          },
          tooltip: {
            callbacks: {
              label: function(context) {
                return '平均: ' + context.parsed.y.toFixed(1) + '点'
              }
            }
          }
        },
        scales: {
          y: {
            beginAtZero: true,
            max: 100,
            ticks: {
              callback: function(value) {
                return value + '点'
              }
            }
          }
        }
      }
    })
  }

  renderRadarChart(ctx, data) {
    // 最新の投稿のスコアを取得
    const latestIndex = data.scores.length - 1
    
    new Chart(ctx, {
      type: 'radar',
      data: {
        labels: ['原因分析', '対策具体性', '学び言語化', '再発防止'],
        datasets: [{
          label: 'スコア',
          data: [
            data.cause_scores[latestIndex] || 0,
            data.solution_scores[latestIndex] || 0,
            data.learning_scores[latestIndex] || 0,
            data.prevention_scores[latestIndex] || 0
          ],
          borderColor: '#4F46E5',
          backgroundColor: 'rgba(79, 70, 229, 0.2)',
          pointBackgroundColor: '#4F46E5',
          pointBorderColor: '#fff',
          pointHoverBackgroundColor: '#fff',
          pointHoverBorderColor: '#4F46E5'
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            display: false
          }
        },
        scales: {
          r: {
            beginAtZero: true,
            max: 25,
            ticks: {
              stepSize: 5
            }
          }
        }
      }
    })
  }

  showError() {
    this.canvas.parentElement.innerHTML = `
      <div style="text-align: center; padding: 2rem; color: #EF4444;">
        <p>グラフの読み込みに失敗しました</p>
      </div>
    `
  }
}

// 初期化
function initCharts() {
  const charts = document.querySelectorAll('.chart-canvas')
  charts.forEach(canvas => {
    new ChartRenderer(canvas)
  })
}

document.addEventListener('DOMContentLoaded', initCharts)
document.addEventListener('turbo:load', initCharts)

