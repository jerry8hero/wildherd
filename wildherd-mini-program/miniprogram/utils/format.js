// utils/format.js
// 格式化工具函数

/**
 * 格式化体重
 * @param {number} weight 体重（克）
 */
function formatWeight(weight) {
  if (!weight) return '-'
  if (weight >= 1000) {
    return (weight / 1000).toFixed(2) + ' kg'
  }
  return weight + ' g'
}

/**
 * 格式化体长
 * @param {number} length 体长（厘米）
 */
function formatLength(length) {
  if (!length) return '-'
  return length + ' cm'
}

/**
 * 食物类型翻译
 * @param {string} type 食物类型
 */
function formatFoodType(type) {
  const map = {
    'mouse': '老鼠',
    'pink_mouse': '乳鼠',
    'lizard': '蜥蜴',
    'frog': '蛙类',
    'insect': '昆虫',
    'other': '其他'
  }
  return map[type] || type
}

/**
 * 性别翻译
 * @param {string} gender 性别
 */
function formatGender(gender) {
  const map = {
    'male': '公',
    'female': '母',
    'unknown': '未知'
  }
  return map[gender] || gender
}

/**
 * 繁殖状态翻译
 * @param {string} status 状态
 */
function formatBreedingStatus(status) {
  const map = {
    'available': '可繁殖',
    'bred': '已繁殖',
    'immature': '未成年',
    'resting': '休养中'
  }
  return map[status] || status
}

/**
 * 截断字符串
 * @param {string} str 字符串
 * @param {number} length 长度
 */
function truncate(str, length = 20) {
  if (!str) return ''
  if (str.length <= length) return str
  return str.substring(0, length) + '...'
}

module.exports = {
  formatWeight,
  formatLength,
  formatFoodType,
  formatGender,
  formatBreedingStatus,
  truncate
}
