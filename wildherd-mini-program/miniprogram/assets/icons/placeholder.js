// components/pet-card/pet-card.js
// 宠物卡片组件

Component({
  properties: {
    pet: {
      type: Object,
      value: {}
    }
  },

  methods: {
    onTap() {
      this.triggerEvent('tap', { id: this.data.pet._id })
    }
  }
})
