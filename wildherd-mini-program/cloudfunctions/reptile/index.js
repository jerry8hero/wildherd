// cloudfunctions/reptile/index.js
// 爬宠管理云函数

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

exports.main = async (event, context) => {
  const { action, data } = event
  const openid = getOpenId()

  if (!openid) {
    return response(false, null, '用户未登录')
  }

  try {
    switch (action) {
      case 'getAll':
        // 获取当前用户所有爬宠
        const reptiles = await db.collection('reptiles')
          .where({ userId: openid })
          .orderBy('updatedAt', 'desc')
          .get()
        return response(true, reptiles.data)

      case 'getById':
        // 获取单个爬宠详情
        if (!data._id) {
          return response(false, null, '缺少爬宠 ID')
        }
        const reptile = await db.collection('reptiles')
          .doc(data._id)
          .get()
        // 验证归属
        if (!reptile.data || reptile.data.userId !== openid) {
          return response(false, null, '爬宠不存在或无权限访问')
        }
        return response(true, reptile.data)

      case 'add':
        // 添加爬宠
        if (!data.name || !data.species) {
          return response(false, null, '名称和物种不能为空')
        }
        const newReptile = {
          userId: openid,
          name: data.name,
          species: data.species,
          speciesChinese: data.speciesChinese || '',
          gender: data.gender || 'unknown',
          birthDate: data.birthDate || null,
          weight: data.weight || null,
          length: data.length || null,
          imageUrl: data.imageUrl || '',
          acquisitionDate: data.acquisitionDate || null,
          breedingStatus: data.breedingStatus || 'available',
          notes: data.notes || '',
          createdAt: new Date(),
          updatedAt: new Date()
        }
        const addRes = await db.collection('reptiles').add({ data: newReptile })
        newReptile._id = addRes._id
        return response(true, newReptile, '添加成功')

      case 'update':
        // 更新爬宠
        if (!data._id) {
          return response(false, null, '缺少爬宠 ID')
        }
        // 验证归属
        const toUpdate = await db.collection('reptiles').doc(data._id).get()
        if (!toUpdate.data || toUpdate.data.userId !== openid) {
          return response(false, null, '爬宠不存在或无权限访问')
        }

        const { _id, userId, createdAt, ...updateData } = data
        updateData.updatedAt = new Date()

        await db.collection('reptiles').doc(_id).update({ data: updateData })
        return response(true, null, '更新成功')

      case 'delete':
        // 删除爬宠
        if (!data._id) {
          return response(false, null, '缺少爬宠 ID')
        }
        // 验证归属
        const toDelete = await db.collection('reptiles').doc(data._id).get()
        if (!toDelete.data || toDelete.data.userId !== openid) {
          return response(false, null, '爬宠不存在或无权限访问')
        }

        await db.collection('reptiles').doc(data._id).remove()

        // 同时删除关联的喂食记录和健康记录
        await db.collection('feeding_records').where({ reptileId: data._id }).remove()
        await db.collection('health_records').where({ reptileId: data._id }).remove()

        return response(true, null, '删除成功')

      case 'getStats':
        // 获取统计信息
        const countRes = await db.collection('reptiles')
          .where({ userId: openid })
          .count()
        return response(true, { total: countRes.total })

      default:
        return response(false, null, '未知操作')
    }
  } catch (e) {
    console.error('爬宠云函数错误', e)
    return response(false, null, e.message)
  }
}
