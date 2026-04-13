// cloudfunctions/weather/index.js
// 天气查询云函数 - 使用和风天气 API

const cloud = require('wx-server-sdk')
const https = require('https')
cloud.init({ env: cloud.DYNAMIC_CURRENT_ENV })

// 统一响应格式
const response = (success, data, message) => ({
  success,
  data,
  message
})

// 和风天气 API 配置
// 请替换为你的和风天气 KEY
const HEFENG_KEY = 'YOUR_HEFENG_KEY'
const HEFENG_BASE_URL = 'https://devapi.qweather.com/v7'

/**
 * 发送 HTTPS 请求
 */
function request(url) {
  return new Promise((resolve, reject) => {
    https.get(url, (res) => {
      let data = ''
      res.on('data', chunk => data += chunk)
      res.on('end', () => {
        try {
          resolve(JSON.parse(data))
        } catch (e) {
          reject(e)
        }
      })
    }).on('error', reject)
  })
}

/**
 * 获取实时天气
 */
async function getNowWeather(location) {
  const url = `${HEFENG_BASE_URL}/weather/now?location=${location}&key=${HEFENG_KEY}`
  return request(url)
}

/**
 * 获取逐天预报
 */
async function getDailyWeather(location, days = 3) {
  const url = `${HEFENG_BASE_URL}/weather/3d?location=${location}&key=${HEFENG_KEY}`
  return request(url)
}

/**
 * 获取空气指数
 */
async function getAirQuality(location) {
  const url = `${HEFENG_BASE_URL}/air/now?location=${location}&key=${HEFENG_KEY}`
  return request(url)
}

exports.main = async (event, context) => {
  const { action, data } = event

  try {
    switch (action) {
      case 'getWeather':
        // 获取天气信息
        if (!data.lat || !data.lon) {
          return response(false, null, '缺少位置信息')
        }

        // 将经纬度转换为和风天气需要的 location 格式
        const location = `${data.lon},${data.lat}`

        // 并行请求天气和空气质量
        const [now, daily, air] = await Promise.all([
          getNowWeather(location).catch(() => null),
          getDailyWeather(location).catch(() => null),
          getAirQuality(location).catch(() => null)
        ])

        const weatherData = {
          now: now?.now || null,
          daily: daily?.daily || null,
          air: air?.now || null,
          updateTime: new Date().toISOString()
        }

        return response(true, weatherData)

      case 'getLocation':
        // 获取当前位置（通过微信小程序获取的坐标）
        // 微信小程序的坐标是 wgs84 类型，需要转换
        if (!data.lat || !data.lon) {
          return response(false, null, '缺少位置信息')
        }
        // 和风天气支持 wgs84 坐标，直接使用
        const loc = `${data.lon},${data.lat}`
        return response(true, { location: loc })

      default:
        return response(false, null, '未知操作')
    }
  } catch (e) {
    console.error('天气云函数错误', e)
    return response(false, null, e.message)
  }
}
