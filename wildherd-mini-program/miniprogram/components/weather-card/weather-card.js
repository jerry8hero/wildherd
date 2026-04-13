// components/weather-card/weather-card.js
// 天气卡片组件

Component({
  properties: {
    weather: {
      type: Object,
      value: null
    },
    loading: {
      type: Boolean,
      value: false
    }
  }
})
