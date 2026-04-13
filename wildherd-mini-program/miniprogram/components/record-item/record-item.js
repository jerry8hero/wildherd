// components/record-item/record-item.js
// 记录项组件

Component({
  properties: {
    record: {
      type: Object,
      value: {}
    },
    type: {
      type: String,
      value: 'feeding' // feeding | health
    }
  },

  methods: {
    onDelete() {
      this.triggerEvent('delete', { id: this.data.record._id })
    }
  }
})
