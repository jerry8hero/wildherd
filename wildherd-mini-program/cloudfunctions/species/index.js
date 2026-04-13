// cloudfunctions/species/index.js
// 物种百科云函数 - 只读查询预置数据

const cloud = require('wx-server-sdk')
cloud.init({ env: cloud.DYNAMIC_CURRENT_ENV })

const db = cloud.database()

// 统一响应格式
const response = (success, data, message) => ({
  success,
  data,
  message
})

exports.main = async (event, context) => {
  const { action, data } = event

  try {
    switch (action) {
      case 'getAll':
        // 获取所有物种（分页）
        const pageSize = data.pageSize || 20
        const page = data.page || 1
        const skip = (page - 1) * pageSize

        let query = db.collection('species')

        // 按分类筛选
        if (data.category) {
          query = query.where({ category: data.category })
        }

        const speciesRes = await query
          .orderBy('nameChinese', 'asc')
          .skip(skip)
          .limit(pageSize)
          .get()

        // 获取总数
        const countRes = await query.count()

        return response(true, {
          list: speciesRes.data,
          total: countRes.total,
          page,
          pageSize
        })

      case 'getById':
        // 获取物种详情
        if (!data.id) {
          return response(false, null, '缺少物种 ID')
        }
        const species = await db.collection('species').doc(data.id).get()
        if (!species.data) {
          return response(false, null, '物种不存在')
        }
        return response(true, species.data)

      case 'search':
        // 搜索物种
        if (!data.keyword) {
          return response(false, null, '请输入搜索关键词')
        }
        const keyword = data.keyword
        const searchRes = await db.collection('species')
          .where(
            db.command.or([
              { nameChinese: db.RegExp({ regexp: keyword, options: 'i' }) },
              { nameEnglish: db.RegExp({ regexp: keyword, options: 'i' }) }
            ])
          )
          .limit(20)
          .get()
        return response(true, searchRes.data)

      case 'getCategories':
        // 获取所有分类
        const categories = [
          { id: 'snake', name: '蛇类', icon: 'snake' },
          { id: 'lizard', name: '蜥蜴类', icon: 'lizard' },
          { id: 'turtle', name: '龟类', icon: 'turtle' },
          { id: 'frog', name: '蛙类', icon: 'frog' },
          { id: 'salamander', name: '蝾螈类', icon: 'salamander' },
          { id: 'other', name: '其他', icon: 'other' }
        ]
        return response(true, categories)

      case 'getByCategory':
        // 按分类获取物种
        if (!data.category) {
          return response(false, null, '缺少分类 ID')
        }
        const categoryRes = await db.collection('species')
          .where({ category: data.category })
          .orderBy('nameChinese', 'asc')
          .get()
        return response(true, categoryRes.data)

      default:
        return response(false, null, '未知操作')
    }
  } catch (e) {
    console.error('物种百科云函数错误', e)
    return response(false, null, e.message)
  }
}
