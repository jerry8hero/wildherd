// services/weather.js
// 天气 API 服务

const api = require('./api.js')

/**
 * 获取天气信息
 * @param {number} lat 纬度
 * @param {number} lon 经度
 */
function getWeather(lat, lon) {
  return api.call('weather', {
    action: 'getWeather',
    data: { lat, lon }
  })
}

/**
 * 获取当前位置坐标
 */
function getLocation() {
  return new Promise((resolve, reject) => {
    wx.getLocation({
      type: 'gcj02',
      success: resolve,
      fail: reject
    })
  })
}

/**
 * 获取当前位置天气
 */
async function getCurrentWeather() {
  try {
    const location = await getLocation()
    const res = await getWeather(location.latitude, location.longitude)
    return res
  } catch (e) {
    console.error('获取天气失败', e)
    throw e
  }
}

module.exports = {
  getWeather,
  getLocation,
  getCurrentWeather
}
