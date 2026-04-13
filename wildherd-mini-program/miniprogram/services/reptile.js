// services/reptile.js
// 爬宠相关 API 服务

const api = require('./api.js')

/**
 * 获取所有爬宠
 */
function getAll() {
  return api.call('reptile', { action: 'getAll' })
}

/**
 * 获取单个爬宠详情
 * @param {string} id 爬宠 ID
 */
function getById(id) {
  return api.call('reptile', { action: 'getById', data: { _id: id } })
}

/**
 * 添加爬宠
 * @param {object} data 爬宠数据
 */
function add(data) {
  return api.call('reptile', { action: 'add', data })
}

/**
 * 更新爬宠
 * @param {object} data 爬宠数据（包含 _id）
 */
function update(data) {
  return api.call('reptile', { action: 'update', data })
}

/**
 * 删除爬宠
 * @param {string} id 爬宠 ID
 */
function remove(id) {
  return api.call('reptile', { action: 'delete', data: { _id: id } })
}

/**
 * 获取统计信息
 */
function getStats() {
  return api.call('reptile', { action: 'getStats' })
}

module.exports = {
  getAll,
  getById,
  add,
  update,
  remove,
  getStats
}
