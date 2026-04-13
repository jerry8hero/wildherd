// pages/feeding/feeding.js
// 喂食记录页面

const feedingService = require('../../services/feeding.js')
const reptileService = require('../../services/reptile.js')

Page({
  data: {
    records: [],
    pets: [],
    selectedPetId: '',
    loading: true,
    showAddModal: false,
    formData: {
      reptileId: '',
      foodType: '',
      foodAmount: '',
      feedingTime: '',
      notes: ''
    },
    foodTypes: [
      { text: '老鼠', value: 'mouse' },
      { text: '乳鼠', value: 'pink_mouse' },
      { text: '蜥蜴', value: 'lizard' },
      { text: '蛙类', value: 'frog' },
      { text: '昆虫', value: 'insect' },
      { text: '其他', value: 'other' }
    ]
  },

  onLoad(options) {
    if (options.reptileId) {
      this.data.selectedPetId = options.reptileId
      this.data.formData.reptileId = options.reptileId
    }
    this.loadPets()
  },

  onShow() {
    this.loadData()
  },

  async loadPets() {
    try {
      const res = await reptileService.getAll()
      if (res.success) {
        this.setData({ pets: res.data })
        // 如果没有选中宠物且有宠物，默认选中第一个
        if (!this.data.selectedPetId && res.data.length > 0) {
          this.data.selectedPetId = res.data[0]._id
          this.data.formData.reptileId = res.data[0]._id
        }
      }
    } catch (e) {}
  },

  async loadData() {
    this.setData({ loading: true })
    try {
      const res = await feedingService.getAll(this.data.selectedPetId)
      this.setData({
        records: res.success ? res.data : [],
        loading: false
      })
    } catch (e) {
      this.setData({ loading: false })
    }
  },

  // 选择宠物筛选
  onPetChange(e) {
    const petId = this.data.pets[e.detail.value]._id
    this.setData({ selectedPetId: petId })
    this.loadData()
  },

  // 打开添加弹窗
  openAddModal() {
    if (!this.data.pets.length) {
      wx.showToast({ title: '请先添加爬宠', icon: 'none' })
      return
    }
    const now = new Date()
    const dateStr = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(now.getDate()).padStart(2, '0')}`
    this.setData({
      showAddModal: true,
      'formData': {
        reptileId: this.data.selectedPetId || this.data.pets[0]?._id || '',
        foodType: '',
        foodAmount: '',
        feedingTime: dateStr,
        notes: ''
      }
    })
  },

  // 关闭弹窗
  closeModal() {
    this.setData({ showAddModal: false })
  },

  // 表单变化
  onFormChange(e) {
    const { field } = e.currentTarget.dataset
    this.setData({ [`formData.${field}`]: e.detail })
  },

  // 提交记录
  async submitRecord() {
    const { formData } = this.data
    if (!formData.reptileId) {
      wx.showToast({ title: '请选择爬宠', icon: 'none' })
      return
    }
    if (!formData.foodType) {
      wx.showToast({ title: '请选择食物类型', icon: 'none' })
      return
    }

    try {
      const res = await feedingService.add({
        ...formData,
        foodAmount: formData.foodAmount ? parseFloat(formData.foodAmount) : null
      })
      if (res.success) {
        wx.showToast({ title: '添加成功', icon: 'success' })
        this.closeModal()
        this.loadData()
      } else {
        wx.showToast({ title: res.message || '添加失败', icon: 'none' })
      }
    } catch (e) {
      wx.showToast({ title: '添加失败', icon: 'none' })
    }
  },

  // 删除记录
  async deleteRecord(e) {
    const id = e.currentTarget.dataset.id
    wx.showModal({
      title: '确认删除',
      content: '确定要删除这条记录吗？',
      confirmColor: '#f44336',
      success: async (res) => {
        if (res.confirm) {
          try {
            const result = await feedingService.remove(id)
            if (result.success) {
              wx.showToast({ title: '删除成功', icon: 'success' })
              this.loadData()
            }
          } catch (e) {
            wx.showToast({ title: '删除失败', icon: 'none' })
          }
        }
      }
    })
  }
})
