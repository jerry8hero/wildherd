// utils/date.js
// 日期工具函数

/**
 * 格式化日期
 * @param {Date|string|number} date 日期
 * @param {string} format 格式 yyyy-MM-dd HH:mm:ss
 */
function formatDate(date, format = 'yyyy-MM-dd') {
  if (!date) return ''
  const d = new Date(date)
  if (isNaN(d.getTime())) return ''

  const year = d.getFullYear()
  const month = String(d.getMonth() + 1).padStart(2, '0')
  const day = String(d.getDate()).padStart(2, '0')
  const hours = String(d.getHours()).padStart(2, '0')
  const minutes = String(d.getMinutes()).padStart(2, '0')
  const seconds = String(d.getSeconds()).padStart(2, '0')

  return format
    .replace('yyyy', year)
    .replace('MM', month)
    .replace('dd', day)
    .replace('HH', hours)
    .replace('mm', minutes)
    .replace('ss', seconds)
}

/**
 * 获取相对时间描述
 * @param {Date|string|number} date 日期
 */
function getRelativeTime(date) {
  if (!date) return ''
  const d = new Date(date)
  const now = new Date()
  const diff = now - d

  const seconds = Math.floor(diff / 1000)
  const minutes = Math.floor(seconds / 60)
  const hours = Math.floor(minutes / 60)
  const days = Math.floor(hours / 24)

  if (days > 7) {
    return formatDate(date, 'MM-dd')
  } else if (days > 0) {
    return `${days}天前`
  } else if (hours > 0) {
    return `${hours}小时前`
  } else if (minutes > 0) {
    return `${minutes}分钟前`
  } else {
    return '刚刚'
  }
}

/**
 * 计算年龄
 * @param {string} birthDate 出生日期 yyyy-MM-dd
 */
function calculateAge(birthDate) {
  if (!birthDate) return ''
  const birth = new Date(birthDate)
  const now = new Date()

  let years = now.getFullYear() - birth.getFullYear()
  let months = now.getMonth() - birth.getMonth()

  if (months < 0) {
    years--
    months += 12
  }

  if (years > 0) {
    return `${years}岁${months > 0 ? months + '月' : ''}`
  } else if (months > 0) {
    return `${months}月`
  } else {
    const days = Math.floor((now - birth) / (1000 * 60 * 60 * 24))
    return `${days}天`
  }
}

module.exports = {
  formatDate,
  getRelativeTime,
  calculateAge
}
