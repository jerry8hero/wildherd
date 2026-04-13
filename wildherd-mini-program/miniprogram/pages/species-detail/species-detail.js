// pages/species-detail/species-detail.js
// 物种详情页面

const speciesService = require('../../services/species.js')

Page({
  data: {
    species: null,
    loading: true
  },

  onLoad(options) {
    if (options.id) {
      this.loadSpecies(options.id)
    }
  },

  async loadSpecies(id) {
    this.setData({ loading: true })
    try {
      const res = await speciesService.getById(id)
      if (res.success && res.data) {
        this.setData({ species: res.data, loading: false })
      } else {
        wx.showToast({ title: '获取详情失败', icon: 'none' })
        this.setData({ loading: false })
      }
    } catch (e) {
      wx.showToast({ title: '加载失败', icon: 'none' })
      this.setData({ loading: false })
    }
  }
})
