// services/api.js
// 云函数调用封装

const cloud = require('./cloud.js')

/**
 * 调用云函数的便捷方法
 * @param {string} name 云函数名称
 * @param {object} data 请求参数
 */
async function call(name, data = {}) {
  try {
    wx.showLoading({ title: '加载中...', mask: true })
    const res = await cloud.callFunction(name, data)
    wx.hideLoading()
    return res
  } catch (e) {
    wx.hideLoading()
    wx.showToast({
      title: e.message || '请求失败',
      icon: 'none'
    })
    throw e
  }
}

module.exports = { call }
