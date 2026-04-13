// pages/pet-edit/pet-edit.js
// 编辑宠物页面

const reptileService = require('../../services/reptile.js')

Page({
  data: {
    petId: '',
    formData: {
      name: '',
      species: '',
      speciesChinese: '',
      gender: 'unknown',
      birthDate: '',
      weight: '',
      length: '',
      acquisitionDate: '',
      breedingStatus: 'available',
      notes: '',
      imageUrl: ''
    },
    submitting: false
  },

  onLoad(options) {
    if (options.id) {
      this.data.petId = options.id
      this.loadPet()
    }
  },

  async loadPet() {
    wx.showLoading({ title: '加载中...' })
    try {
      const res = await reptileService.getById(this.data.petId)
      if (res.success && res.data) {
        const pet = res.data
        this.setData({
          formData: {
            ...pet,
            weight: pet.weight || '',
            length: pet.length || ''
          }
        })
      } else {
        wx.showToast({ title: '获取详情失败', icon: 'none' })
      }
    } catch (e) {
      wx.showToast({ title: '加载失败', icon: 'none' })
    }
    wx.hideLoading()
  },

  onFieldChange(e) {
    const { field } = e.currentTarget.dataset
    this.setData({
      [`formData.${field}`]: e.detail
    })
  },

  onGenderChange(e) {
    this.setData({ 'formData.gender': e.detail.value })
  },

  onStatusChange(e) {
    this.setData({ 'formData.breedingStatus': e.detail.value })
  },

  onDateChange(e) {
    const { field } = e.currentTarget.dataset
    this.setData({ [`formData.${field}`]: e.detail.value })
  },

  chooseImage() {
    wx.chooseMedia({
      count: 1,
      mediaType: ['image'],
      sourceType: ['album', 'camera'],
      success: async (res) => {
        const tempFile = res.tempFiles[0]
        if (tempFile.size > 2 * 1024 * 1024) {
          wx.showToast({ title: '图片不能超过2MB', icon: 'none' })
          return
        }
        wx.showLoading({ title: '上传中...' })
        try {
          const uploadRes = await wx.cloud.uploadFile({
            cloudPath: `reptiles/${Date.now()}.${tempFile.tempFilePath.split('.').pop()}`,
            filePath: tempFile.tempFilePath
          })
          this.setData({ 'formData.imageUrl': uploadRes.fileID })
          wx.hideLoading()
        } catch (e) {
          wx.hideLoading()
          wx.showToast({ title: '上传失败', icon: 'none' })
        }
      }
    })
  },

  async submit() {
    const { formData } = this.data
    if (!formData.name.trim()) {
      wx.showToast({ title: '请输入名称', icon: 'none' })
      return
    }
    if (!formData.species.trim()) {
      wx.showToast({ title: '请输入物种', icon: 'none' })
      return
    }

    this.setData({ submitting: true })
    try {
      const data = {
        _id: this.data.petId,
        ...formData,
        weight: formData.weight ? parseFloat(formData.weight) : null,
        length: formData.length ? parseFloat(formData.length) : null
      }
      const res = await reptileService.update(data)
      if (res.success) {
        wx.showToast({ title: '更新成功', icon: 'success' })
        setTimeout(() => wx.navigateBack(), 1500)
      } else {
        wx.showToast({ title: res.message || '更新失败', icon: 'none' })
      }
    } catch (e) {
      wx.showToast({ title: '更新失败', icon: 'none' })
    } finally {
      this.setData({ submitting: false })
    }
  }
})
