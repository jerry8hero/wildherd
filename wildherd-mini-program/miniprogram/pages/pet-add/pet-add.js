// pages/pet-add/pet-add.js
// 添加宠物页面

const reptileService = require('../../services/reptile.js')

Page({
  data: {
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
      notes: ''
    },
    genderOptions: [
      { text: '未知', value: 'unknown' },
      { text: '公', value: 'male' },
      { text: '母', value: 'female' }
    ],
    statusOptions: [
      { text: '可繁殖', value: 'available' },
      { text: '已繁殖', value: 'bred' },
      { text: '未成年', value: 'immature' },
      { text: '休养中', value: 'resting' }
    ],
    submitting: false
  },

  onLoad() {
    // 如果是编辑模式，接收参数
  },

  // 表单输入处理
  onFieldChange(e) {
    const { field } = e.currentTarget.dataset
    const value = e.detail
    this.setData({
      [`formData.${field}`]: value
    })
  },

  // 性别选择
  onGenderChange(e) {
    this.setData({
      'formData.gender': e.detail.value
    })
  },

  // 繁殖状态选择
  onStatusChange(e) {
    this.setData({
      'formData.breedingStatus': e.detail.value
    })
  },

  // 日期选择
  onDateChange(e) {
    const { field } = e.currentTarget.dataset
    this.setData({
      [`formData.${field}`]: e.detail.value
    })
  },

  // 选择图片
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
          this.setData({
            'formData.imageUrl': uploadRes.fileID
          })
          wx.hideLoading()
          wx.showToast({ title: '上传成功', icon: 'success' })
        } catch (e) {
          wx.hideLoading()
          wx.showToast({ title: '上传失败', icon: 'none' })
        }
      }
    })
  },

  // 提交表单
  async submit() {
    const { formData } = this.data

    // 验证必填项
    if (!formData.name.trim()) {
      wx.showToast({ title: '请输入宠物名称', icon: 'none' })
      return
    }
    if (!formData.species.trim()) {
      wx.showToast({ title: '请输入物种名称', icon: 'none' })
      return
    }

    this.setData({ submitting: true })

    try {
      // 转换数值类型
      const data = {
        ...formData,
        weight: formData.weight ? parseFloat(formData.weight) : null,
        length: formData.length ? parseFloat(formData.length) : null
      }

      const res = await reptileService.add(data)
      if (res.success) {
        wx.showToast({ title: '添加成功', icon: 'success' })
        setTimeout(() => {
          wx.navigateBack()
        }, 1500)
      } else {
        wx.showToast({ title: res.message || '添加失败', icon: 'none' })
      }
    } catch (e) {
      wx.showToast({ title: '添加失败', icon: 'none' })
    } finally {
      this.setData({ submitting: false })
    }
  }
})
