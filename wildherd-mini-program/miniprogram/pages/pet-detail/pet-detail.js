// pages/pet-detail/pet-detail.js
// 宠物详情页面

const reptileService = require('../../services/reptile.js')
const feedingService = require('../../services/feeding.js')
const healthService = require('../../services/health.js')

Page({
  data: {
    pet: null,
    feedingRecords: [],
    healthRecords: [],
    loading: true,
    activeTab: 'info'
  },

  onLoad(options) {
    if (options.id) {
      this.data.petId = options.id
      this.loadData()
    }
  },

  async loadData() {
    this.setData({ loading: true })

    try {
      // 获取宠物详情
      const petRes = await reptileService.getById(this.data.petId)
      if (!petRes.success) {
        wx.showToast({ title: '获取详情失败', icon: 'none' })
        return
      }

      // 获取喂食记录
      const feedingRes = await feedingService.getByReptile(this.data.petId)
      // 获取健康记录
      const healthRes = await healthService.getByReptile(this.data.petId)

      this.setData({
        pet: petRes.data,
        feedingRecords: feedingRes.success ? feedingRes.data : [],
        healthRecords: healthRes.success ? healthRes.data : [],
        loading: false
      })
    } catch (e) {
      console.error('加载失败', e)
      this.setData({ loading: false })
    }
  },

  // 切换标签
  onTabChange(e) {
    this.setData({ activeTab: e.detail.name })
  },

  // 编辑宠物
  goToEdit() {
    wx.navigateTo({
      url: `/pages/pet-edit/pet-edit?id=${this.data.petId}`
    })
  },

  // 添加喂食记录
  goToAddFeeding() {
    wx.navigateTo({
      url: `/pages/feeding/feeding?reptileId=${this.data.petId}&reptileName=${this.data.pet.name}`
    })
  },

  // 添加健康记录
  goToAddHealth() {
    wx.navigateTo({
      url: `/pages/health/health?reptileId=${this.data.petId}&reptileName=${this.data.pet.name}`
    })
  },

  // 删除宠物
  confirmDelete() {
    wx.showModal({
      title: '确认删除',
      content: `确定要删除 ${this.data.pet.name} 吗？此操作不可恢复！`,
      confirmColor: '#f44336',
      success: async (res) => {
        if (res.confirm) {
          await this.deletePet()
        }
      }
    })
  },

  async deletePet() {
    wx.showLoading({ title: '删除中...' })
    try {
      const res = await reptileService.remove(this.data.petId)
      if (res.success) {
        wx.showToast({ title: '删除成功', icon: 'success' })
        setTimeout(() => {
          wx.navigateBack()
        }, 1500)
      } else {
        wx.showToast({ title: res.message || '删除失败', icon: 'none' })
      }
    } catch (e) {
      wx.showToast({ title: '删除失败', icon: 'none' })
    }
    wx.hideLoading()
  },

  // 预览图片
  previewImage() {
    if (this.data.pet.imageUrl) {
      wx.previewImage({
        urls: [this.data.pet.imageUrl]
      })
    }
  }
})
