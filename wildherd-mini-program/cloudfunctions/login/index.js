// cloudfunctions/login/index.js
// 微信登录云函数 - 获取 OpenID 和用户信息

const cloud = require('wx-server-sdk')
cloud.init({ env: cloud.DYNAMIC_CURRENT_ENV })

const db = cloud.database()
const MAX_LOGIN_DAYS = 7 // 记住登录状态的天数

// 统一响应格式
const response = (success, data, message) => ({
  success,
  data,
  message
})

exports.main = async (event, context) => {
  const wxContext = cloud.getWXContext()
  const openid = wxContext.OPENID

  if (!openid) {
    return response(false, null, '获取 OpenID 失败')
  }

  try {
    // 查询用户是否已存在
    const userRes = await db.collection('users').where({ openid }).get()

    let userInfo = {}

    if (userRes.data && userRes.data.length > 0) {
      // 用户已存在，更新登录时间
      userInfo = userRes.data[0]
      await db.collection('users').doc(userInfo._id).update({
        data: {
          lastLoginAt: new Date(),
          loginDays: db.command.inc(1)
        }
      })
    } else {
      // 新用户，创建用户记录
      const now = new Date()
      const newUser = {
        openid,
        nickName: event.userInfo?.nickName || '新用户',
        avatarUrl: event.userInfo?.avatarUrl || '',
        level: 'beginner',
        language: 'zh',
        createdAt: now,
        updatedAt: now,
        lastLoginAt: now,
        loginDays: 1
      }

      const addRes = await db.collection('users').add({ data: newUser })
      newUser._id = addRes._id
      userInfo = newUser
    }

    return response(true, {
      openid,
      userInfo: {
        nickName: userInfo.nickName,
        avatarUrl: userInfo.avatarUrl,
        level: userInfo.level,
        language: userInfo.language
      }
    })
  } catch (e) {
    console.error('登录云函数错误', e)
    return response(false, null, e.message)
  }
}
