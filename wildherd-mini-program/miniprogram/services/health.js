// services/health.js
// 健康记录 API 服务

const api = require('./api.js')

/**
 * 获取所有健康记录
 * @param {string} reptileId 可选，按爬宠筛选
 */
function getAll(reptileId) {
  return api.call('health', { action: 'getAll', data: { reptileId } })
}

/**
 * 获取指定爬宠的健康记录
 * @param {string} reptileId 爬宠 ID
 */
function getByReptile(reptileId) {
  return api.call('health', { action: 'getByReptile', data: { reptileId } })
}

/**
 * 添加健康记录
 * @param {object} data 记录数据
 */
function add(data) {
  return api.call('health', { action: 'add', data })
}

/**
 * 更新健康记录
 * @param {object} data 记录数据（包含 _id）
 */
function update(data) {
  return api.call('health', { action: 'update', data })
}

/**
 * 删除健康记录
 * @param {string} id 记录 ID
 */
function remove(id) {
  return api.call('health', { action: 'delete', data: { _id: id } })
}

/**
 * 获取最近健康记录
 */
function getRecent() {
  return api.call('health', { action: 'getRecent' })
}

module.exports = {
  getAll,
  getByReptile,
  add,
  update,
  remove,
  getRecent
}
