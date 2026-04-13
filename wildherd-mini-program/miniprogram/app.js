// WildHerd 微信小程序入口文件
const cloud = require('./services/cloud.js')

App({
  globalData: {
    userInfo: null,
    openid: null,
    isLogin: false,
    language: 'zh'
  },

  onLaunch: async function() {
    // 初始化云开发
    cloud.init()

    // 检查登录状态
    await this.checkLogin()

    // 检查是否有导入文件（数据迁移）
    this.checkImportFile()
  },

  // 检查微信登录
  async checkLogin() {
    try {
      const res = await cloud.callFunction('login', {})
      if (res.success && res.data.openid) {
        this.globalData.openid = res.data.openid
        this.globalData.isLogin = true
        this.globalData.userInfo = res.data.userInfo
      }
    } catch (e) {
      console.error('登录失败', e)
    }
  },

  // 检查导入文件
  checkImportFile() {
    const fs = wx.getFileSystemManager()
    try {
      const fileContent = fs.readFileSync(
        `${wx.env.USER_DATA_PATH}/reptiles_backup.json`,
        'utf-8'
      )
      const data = JSON.parse(fileContent)

      wx.showModal({
        title: '检测到导入文件',
        content: `是否迁移 ${data.data.reptiles?.length || 0} 只爬宠到小程序？`,
        confirmText: '立即迁移',
        cancelText: '稍后',
        success: async (res) => {
          if (res.confirm) {
            await this.migrateData(data)
          }
        }
      })
    } catch (e) {
      // 文件不存在，跳过
    }
  },

  // 数据迁移
  async migrateData(data) {
    wx.showLoading({ title: '迁移中...' })

    try {
      const { reptiles, feedingRecords, healthRecords } = data.data || {}

      // 迁移爬宠
      if (reptiles && reptiles.length > 0) {
        for (const reptile of reptiles) {
          await cloud.callFunction('reptile', {
            action: 'add',
            data: reptile
          })
        }
      }

      // 迁移喂食记录
      if (feedingRecords && feedingRecords.length > 0) {
        for (const record of feedingRecords) {
          await cloud.callFunction('feeding', {
            action: 'add',
            data: record
          })
        }
      }

      // 迁移健康记录
      if (healthRecords && healthRecords.length > 0) {
        for (const record of healthRecords) {
          await cloud.callFunction('health', {
            action: 'add',
            data: record
          })
        }
      }

      // 删除导入文件
      const fs = wx.getFileSystemManager()
      try {
        fs.unlinkSync(`${wx.env.USER_DATA_PATH}/reptiles_backup.json`)
      } catch (e) {}

      wx.hideLoading()
      wx.showToast({
        title: '迁移成功',
        icon: 'success'
      })
    } catch (e) {
      wx.hideLoading()
      wx.showToast({
        title: '迁移失败',
        icon: 'none'
      })
      console.error('迁移失败', e)
    }
  }
})
