// pages/index/index.js
// 首页 - 宠物列表 + 天气 + 快捷入口

const reptileService = require('../../services/reptile.js')
const weatherService = require('../../services/weather.js')

Page({
  data: {
    pets: [],
    weather: null,
    loading: true,
    hasLocation: false,
    stats: {
      total: 0,
      feedingToday: 0
    }
  },

  onLoad() {
    this.checkLogin()
  },

  onShow() {
    // 每次显示页面时刷新数据
    if (this.data.hasLocation) {
      this.loadData()
    }
  },

  onPullDownRefresh() {
    this.loadData()
    wx.stopPullDownRefresh()
  },

  // 检查登录状态
  checkLogin() {
    const app = getApp()
    if (!app.globalData.isLogin) {
      // 未登录，跳转到登录引导
      this.showLoginTip()
    } else {
      this.init()
    }
  },

  showLoginTip() {
    wx.showModal({
      title: '提示',
      content: '正在获取微信授权，请稍后...',
      showCancel: false,
      success: () => {
        setTimeout(() => this.checkLogin(), 1000)
      }
    })
  },

  async init() {
    // 获取位置信息
    try {
      await weatherService.getLocation()
      this.data.hasLocation = true
      this.loadData()
    } catch (e) {
      console.error('获取位置失败', e)
      this.setData({ loading: false })
      wx.showToast({
        title: '请开启位置权限以获取天气',
        icon: 'none'
      })
    }
  },

  async loadData() {
    this.setData({ loading: true })

    try {
      // 并行加载宠物列表和天气
      const [petsRes, weatherRes] = await Promise.all([
        reptileService.getAll(),
        this.data.hasLocation ? weatherService.getCurrentWeather().catch(() => null) : Promise.resolve(null)
      ])

      this.setData({
        pets: petsRes.success ? petsRes.data : [],
        weather: weatherRes?.success ? weatherRes.data : null,
        loading: false,
        'stats.total': petsRes.success ? petsRes.data.length : 0
      })
    } catch (e) {
      console.error('加载数据失败', e)
      this.setData({ loading: false })
    }
  },

  // 跳转到添加宠物
  goToAddPet() {
    wx.navigateTo({ url: '/pages/pet-add/pet-add' })
  },

  // 跳转到宠物详情
  goToPetDetail(e) {
    const id = e.currentTarget.dataset.id
    wx.navigateTo({ url: `/pages/pet-detail/pet-detail?id=${id}` })
  },

  // 跳转到喂食记录
  goToFeeding() {
    wx.navigateTo({ url: '/pages/feeding/feeding' })
  },

  // 跳转到健康记录
  goToHealth() {
    wx.navigateTo({ url: '/pages/health/health' })
  },

  // 刷新天气
  async refreshWeather() {
    if (!this.data.hasLocation) return

    wx.showLoading({ title: '刷新天气...' })
    try {
      const res = await weatherService.getCurrentWeather()
      this.setData({ weather: res.success ? res.data : null })
    } catch (e) {
      wx.showToast({ title: '刷新失败', icon: 'none' })
    }
    wx.hideLoading()
  }
})
