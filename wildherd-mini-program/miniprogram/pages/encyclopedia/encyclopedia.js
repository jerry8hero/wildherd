// pages/encyclopedia/encyclopedia.js
// 物种百科页面

const speciesService = require('../../services/species.js')

Page({
  data: {
    categories: [],
    speciesList: [],
    selectedCategory: '',
    searchKeyword: '',
    loading: true,
    page: 1,
    hasMore: true
  },

  onLoad() {
    this.loadCategories()
  },

  onPullDownRefresh() {
    this.setData({ page: 1, speciesList: [], hasMore: true })
    this.loadSpeciesList()
    wx.stopPullDownRefresh()
  },

  onReachBottom() {
    if (this.data.hasMore) {
      this.data.page++
      this.loadSpeciesList(true)
    }
  },

  async loadCategories() {
    try {
      const res = await speciesService.getCategories()
      if (res.success) {
        this.setData({ categories: res.data })
        // 默认选中第一个分类
        if (res.data.length > 0) {
          this.data.selectedCategory = res.data[0].id
        }
        this.loadSpeciesList()
      }
    } catch (e) {
      this.setData({ loading: false })
    }
  },

  async loadSpeciesList(append = false) {
    if (this.data.loading) return
    this.setData({ loading: true })

    try {
      const res = await speciesService.getAll(this.data.page, 20, this.data.selectedCategory)
      if (res.success) {
        const list = res.data.list || []
        this.setData({
          speciesList: append ? [...this.data.speciesList, ...list] : list,
          hasMore: list.length >= 20,
          loading: false
        })
      } else {
        this.setData({ loading: false })
      }
    } catch (e) {
      this.setData({ loading: false })
    }
  },

  // 选择分类
  onCategoryChange(e) {
    const index = e.detail.value
    const category = this.data.categories[index]
    if (category) {
      this.data.selectedCategory = category.id
      this.setData({ page: 1, speciesList: [], hasMore: true })
      this.loadSpeciesList()
    }
  },

  // 搜索
  onSearch(e) {
    this.data.searchKeyword = e.detail
    this.setData({ page: 1, speciesList: [], hasMore: true })
    this.loadSpeciesList()
  },

  // 点击物种卡片
  goToSpeciesDetail(e) {
    const id = e.currentTarget.dataset.id
    wx.navigateTo({ url: `/pages/species-detail/species-detail?id=${id}` })
  }
})
