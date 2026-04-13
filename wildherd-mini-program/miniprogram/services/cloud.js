// 云开发初始化和调用封装
const cloud = require('wx-server-sdk')

// 云开发初始化
cloud.init({
  env: cloud.DYNAMIC_CURRENT_ENV
})

const db = cloud.database()

// 统一响应格式
const response = (success, data, message) => ({
  success,
  data,
  message
})

/**
 * 调用云函数
 * @param {string} name 云函数名称
 * @param {object} data 请求参数
 * @returns {Promise}
 */
function callFunction(name, data = {}) {
  return wx.cloud.callFunction({
    name,
    data
  }).then(res => {
    if (res.errMsg && res.errMsg.includes('ok')) {
      return res.result
    }
    throw new Error(res.errMsg || '调用失败')
  })
}

/**
 * 获取云数据库引用
 * @param {string} collectionName 集合名称
 */
function collection(collectionName) {
  return db.collection(collectionName)
}

/**
 * 获取用户 openid
 */
function getOpenId() {
  const wxContext = cloud.getWXContext()
  return wxContext.OPENID
}

module.exports = {
  cloud,
  db,
  callFunction,
  collection,
  getOpenId,
  response
}
