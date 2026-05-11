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

module.exports = { response, getOpenId, validateReptile, db }
