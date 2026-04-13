// pages/settings/settings.js
// 设置页面

const app = getApp()

Page({
  data: {
    language: 'zh',
    userInfo: null,
    version: '1.0.0'
  },

  onLoad() {
    this.setData({
      language: app.globalData.language || 'zh',
      userInfo: app.globalData.userInfo
    })
  },

  // 切换语言（预留，v1.1 实现）
  switchLanguage() {
    wx.showToast({
      title: '多语言功能将在 v1.1 版本开放',
      icon: 'none'
    })
  },

  // 关于我们
  showAbout() {
    wx.showModal({
      title: '关于 WildHerd',
      content: 'WildHerd 是一款专注于爬宠管理的微信小程序，帮助爬宠爱好者更好地记录和管理他们的宠物。\n\n版本：1.0.0',
      showCancel: false
    })
  },

  // 导出数据（数据迁移用）
  exportData() {
    wx.showToast({
      title: '导出功能开发中',
      icon: 'none'
    })
  },

  // 清除缓存
  clearCache() {
    wx.showModal({
      title: '清除缓存',
      content: '确定要清除本地缓存吗？',
      success: (res) => {
        if (res.confirm) {
          try {
            wx.clearStorageSync()
            wx.showToast({ title: '清除成功', icon: 'success' })
          } catch (e) {
            wx.showToast({ title: '清除失败', icon: 'none' })
          }
        }
      }
    })
  }
})
