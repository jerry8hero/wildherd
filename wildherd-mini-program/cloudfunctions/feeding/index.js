// cloudfunctions/feeding/index.js
// 喂食记录云函数

const cloud = require('wx-server-sdk')
cloud.init({ env: cloud.DYNAMIC_CURRENT_ENV })

const db = cloud.database()

// 统一响应格式
const response = (success, data, message) => ({
  success,
  data,
  message
})

// 获取用户 openid
const getOpenId = () => cloud.getWXContext().OPENID

// 验证爬宠归属
async function validateReptile(reptileId, openid) {
  if (!reptileId) return false
  const reptile = await db.collection('reptiles').doc(reptileId).get()
  return reptile.data && reptile.data.userId === openid
}

exports.main = async (event, context) => {
  const { action, data } = event
  const openid = getOpenId()

  if (!openid) {
    return response(false, null, '用户未登录')
  }

  try {
    switch (action) {
      case 'getAll':
        // 获取当前用户所有喂食记录（可按爬宠筛选）
        let query = db.collection('feeding_records').where({ userId: openid })
        if (data.reptileId) {
          query = query.where({ userId: openid, reptileId: data.reptileId })
        }
        const feedingRes = await query
          .orderBy('feedingTime', 'desc')
          .get()
        return response(true, feedingRes.data)

      case 'getByReptile':
        // 获取指定爬宠的喂食记录
        if (!data.reptileId) {
          return response(false, null, '缺少爬宠 ID')
        }
        if (!(await validateReptile(data.reptileId, openid))) {
          return response(false, null, '爬宠不存在或无权限访问')
        }
        const records = await db.collection('feeding_records')
          .where({ userId: openid, reptileId: data.reptileId })
          .orderBy('feedingTime', 'desc')
          .get()
        return response(true, records.data)

      case 'add':
        // 添加喂食记录
        if (!data.reptileId || !data.foodType) {
          return response(false, null, '爬宠和食物类型不能为空')
        }
        if (!(await validateReptile(data.reptileId, openid))) {
          return response(false, null, '爬宠不存在或无权限访问')
        }

        const newRecord = {
          userId: openid,
          reptileId: data.reptileId,
          feedingTime: data.feedingTime || new Date(),
          foodType: data.foodType,
          foodAmount: data.foodAmount || null,
          notes: data.notes || '',
          createdAt: new Date()
        }
        const addRes = await db.collection('feeding_records').add({ data: newRecord })
        newRecord._id = addRes._id
        return response(true, newRecord, '添加成功')

      case 'update':
        // 更新喂食记录
        if (!data._id) {
          return response(false, null, '缺少记录 ID')
        }
        const toUpdate = await db.collection('feeding_records').doc(data._id).get()
        if (!toUpdate.data || toUpdate.data.userId !== openid) {
          return response(false, null, '记录不存在或无权限访问')
        }

        const { _id, userId, createdAt, ...updateData } = data
        await db.collection('feeding_records').doc(_id).update({ data: updateData })
        return response(true, null, '更新成功')

      case 'delete':
        // 删除喂食记录
        if (!data._id) {
          return response(false, null, '缺少记录 ID')
        }
        const toDelete = await db.collection('feeding_records').doc(data._id).get()
        if (!toDelete.data || toDelete.data.userId !== openid) {
          return response(false, null, '记录不存在或无权限访问')
        }
        await db.collection('feeding_records').doc(data._id).remove()
        return response(true, null, '删除成功')

      case 'getRecent':
        // 获取最近的喂食记录（用于提醒）
        const recent = await db.collection('feeding_records')
          .where({ userId: openid })
          .orderBy('feedingTime', 'desc')
          .limit(10)
          .get()
        return response(true, recent.data)

      default:
        return response(false, null, '未知操作')
    }
  } catch (e) {
    console.error('喂食记录云函数错误', e)
    return response(false, null, e.message)
  }
}
