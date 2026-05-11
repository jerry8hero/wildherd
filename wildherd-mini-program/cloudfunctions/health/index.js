// cloudfunctions/health/index.js
// 健康记录云函数

const { response, getOpenId, validateReptile, db } = require('shared/utils')

exports.main = async (event, context) => {
  const { action, data } = event
  const openid = getOpenId()

  if (!openid) {
    return response(false, null, '用户未登录')
  }

  try {
    switch (action) {
      case 'getAll':
        // 获取当前用户所有健康记录（可按爬宠筛选）
        let query = db.collection('health_records').where({ userId: openid })
        if (data.reptileId) {
          query = query.where({ userId: openid, reptileId: data.reptileId })
        }
        const healthRes = await query
          .orderBy('recordDate', 'desc')
          .get()
        return response(true, healthRes.data)

      case 'getByReptile':
        // 获取指定爬宠的健康记录
        if (!data.reptileId) {
          return response(false, null, '缺少爬宠 ID')
        }
        if (!(await validateReptile(data.reptileId, openid))) {
          return response(false, null, '爬宠不存在或无权限访问')
        }
        const records = await db.collection('health_records')
          .where({ userId: openid, reptileId: data.reptileId })
          .orderBy('recordDate', 'desc')
          .get()
        return response(true, records.data)

      case 'add':
        // 添加健康记录
        if (!data.reptileId) {
          return response(false, null, '爬宠不能为空')
        }
        if (!(await validateReptile(data.reptileId, openid))) {
          return response(false, null, '爬宠不存在或无权限访问')
        }

        const newRecord = {
          userId: openid,
          reptileId: data.reptileId,
          recordDate: data.recordDate || new Date(),
          weight: data.weight || null,
          length: data.length || null,
          status: data.status || 'normal',
          defecation: data.defecation || 'normal',
          notes: data.notes || '',
          createdAt: new Date()
        }
        const addRes = await db.collection('health_records').add({ data: newRecord })
        newRecord._id = addRes._id
        return response(true, newRecord, '添加成功')

      case 'update':
        // 更新健康记录
        if (!data._id) {
          return response(false, null, '缺少记录 ID')
        }
        const toUpdate = await db.collection('health_records').doc(data._id).get()
        if (!toUpdate.data || toUpdate.data.userId !== openid) {
          return response(false, null, '记录不存在或无权限访问')
        }

        const { _id, userId, createdAt, ...updateData } = data
        await db.collection('health_records').doc(_id).update({ data: updateData })
        return response(true, null, '更新成功')

      case 'delete':
        // 删除健康记录
        if (!data._id) {
          return response(false, null, '缺少记录 ID')
        }
        const toDelete = await db.collection('health_records').doc(data._id).get()
        if (!toDelete.data || toDelete.data.userId !== openid) {
          return response(false, null, '记录不存在或无权限访问')
        }
        await db.collection('health_records').doc(data._id).remove()
        return response(true, null, '删除成功')

      case 'getRecent':
        // 获取最近健康记录
        const recent = await db.collection('health_records')
          .where({ userId: openid })
          .orderBy('recordDate', 'desc')
          .limit(10)
          .get()
        return response(true, recent.data)

      default:
        return response(false, null, '未知操作')
    }
  } catch (e) {
    console.error('健康记录云函数错误', e)
    return response(false, null, e.message)
  }
}
