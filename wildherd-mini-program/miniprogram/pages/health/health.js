// pages/health/health.js
// 健康记录页面

const healthService = require('../../services/health.js')
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
      recordDate: '',
      weight: '',
      length: '',
      status: 'normal',
      defecation: 'normal',
      notes: ''
    },
    statusOptions: [
      { text: '正常', value: 'normal' },
      { text: '异常', value: 'abnormal' }
    ],
    defecationOptions: [
      { text: '正常', value: 'normal' },
      { text: '异常', value: 'abnormal' },
      { text: '便秘', value: 'constipated' }
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
      const res = await healthService.getAll(this.data.selectedPetId)
      this.setData({
        records: res.success ? res.data : [],
        loading: false
      })
    } catch (e) {
      this.setData({ loading: false })
    }
  },

  onPetChange(e) {
    const petId = this.data.pets[e.detail.value]._id
    this.setData({ selectedPetId: petId })
    this.loadData()
  },

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
        recordDate: dateStr,
        weight: '',
        length: '',
        status: 'normal',
        defecation: 'normal',
        notes: ''
      }
    })
  },

  closeModal() {
    this.setData({ showAddModal: false })
  },

  onFormChange(e) {
    const { field } = e.currentTarget.dataset
    this.setData({ [`formData.${field}`]: e.detail })
  },

  async submitRecord() {
    const { formData } = this.data
    if (!formData.reptileId) {
      wx.showToast({ title: '请选择爬宠', icon: 'none' })
      return
    }

    try {
      const res = await healthService.add({
        ...formData,
        weight: formData.weight ? parseFloat(formData.weight) : null,
        length: formData.length ? parseFloat(formData.length) : null
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

  async deleteRecord(e) {
    const id = e.currentTarget.dataset.id
    wx.showModal({
      title: '确认删除',
      content: '确定要删除这条记录吗？',
      confirmColor: '#f44336',
      success: async (res) => {
        if (res.confirm) {
          try {
            const result = await healthService.remove(id)
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
