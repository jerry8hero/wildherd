const cloud = require('wx-server-sdk')
cloud.init({ env: cloud.DYNAMIC_CURRENT_ENV })
const db = cloud.database()

const response = (success, data, message) => ({ success, data, message })

const getOpenId = () => cloud.getWXContext().OPENID

async function validateReptile(reptileId, openid) {
  if (!reptileId) return false
  try {
    const reptile = await db.collection('reptiles').doc(reptileId).get()
    return reptile.data && reptile.data.userId === openid
  } catch {
    return false
  }
}

// 输入校验辅助函数
const isNumber = (v) => typeof v === 'number' && isFinite(v)
const isNonEmptyString = (v) => typeof v === 'string' && v.trim().length > 0
const isInRange = (v, min, max) => isNumber(v) && v >= min && v <= max
const isOneOf = (v, list) => list.includes(v)

module.exports = { response, getOpenId, validateReptile, db, isNumber, isNonEmptyString, isInRange, isOneOf }
