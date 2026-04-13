// services/feeding.js
// 喂食记录 API 服务

const api = require('./api.js')

/**
 * 获取所有喂食记录
 * @param {string} reptileId 可选，按爬宠筛选
 */
function getAll(reptileId) {
  return api.call('feeding', { action: 'getAll', data: { reptileId } })
}

/**
 * 获取指定爬宠的喂食记录
 * @param {string} reptileId 爬宠 ID
 */
function getByReptile(reptileId) {
  return api.call('feeding', { action: 'getByReptile', data: { reptileId } })
}

/**
 * 添加喂食记录
 * @param {object} data 记录数据
 */
function add(data) {
  return api.call('feeding', { action: 'add', data })
}

/**
 * 更新喂食记录
 * @param {object} data 记录数据（包含 _id）
 */
function update(data) {
  return api.call('feeding', { action: 'update', data })
}

/**
 * 删除喂食记录
 * @param {string} id 记录 ID
 */
function remove(id) {
  return api.call('feeding', { action: 'delete', data: { _id: id } })
}

/**
 * 获取最近喂食记录
 */
function getRecent() {
  return api.call('feeding', { action: 'getRecent' })
}

module.exports = {
  getAll,
  getByReptile,
  add,
  update,
  remove,
  getRecent
}
