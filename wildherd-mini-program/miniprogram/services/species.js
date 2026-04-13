// services/species.js
// 物种百科 API 服务

const api = require('./api.js')

/**
 * 获取所有物种（分页）
 * @param {number} page 页码
 * @param {number} pageSize 每页数量
 * @param {string} category 分类筛选
 */
function getAll(page = 1, pageSize = 20, category) {
  return api.call('species', {
    action: 'getAll',
    data: { page, pageSize, category }
  })
}

/**
 * 获取物种详情
 * @param {string} id 物种 ID
 */
function getById(id) {
  return api.call('species', { action: 'getById', data: { id } })
}

/**
 * 搜索物种
 * @param {string} keyword 搜索关键词
 */
function search(keyword) {
  return api.call('species', { action: 'search', data: { keyword } })
}

/**
 * 获取所有分类
 */
function getCategories() {
  return api.call('species', { action: 'getCategories' })
}

/**
 * 按分类获取物种
 * @param {string} category 分类 ID
 */
function getByCategory(category) {
  return api.call('species', { action: 'getByCategory', data: { category } })
}

module.exports = {
  getAll,
  getById,
  search,
  getCategories,
  getByCategory
}
