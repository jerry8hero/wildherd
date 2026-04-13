# 图标目录

本目录需要放置 tabBar 使用的图标文件。

## 需要的图标

| 文件名 | 尺寸 | 说明 |
|-------|------|------|
| home.png | 81×81 px | 首页图标（未选中） |
| home-active.png | 81×81 px | 首页图标（选中） |
| book.png | 81×81 px | 百科图标（未选中） |
| book-active.png | 81×81 px | 百科图标（选中） |
| settings.png | 81×81 px | 设置图标（未选中） |
| settings-active.png | 81×81 px | 设置图标（选中） |
| feeding.png | 60×60 px | 喂食图标 |
| health.png | 60×60 px | 健康图标 |
| empty-pet.png | 200×200 px | 空状态宠物图标 |
| empty-record.png | 200×200 px | 空状态记录图标 |

## 图标获取方式

1. **Vant Weapp 官方图标**：小程序内使用的图标大多来自 Vant Weapp 组件库，无需额外下载
2. **TabBar 图标**：可从 iconfont.cn 下载对应图标，建议使用 Outlined 风格
3. **空状态图标**：可使用 Vant 的 van-empty 组件，或自行设计

## 临时方案

如果暂时没有图标，可以：
1. 使用 Vant 的 `van-icon` 组件替代
2. 在 app.json 中先注释掉 tabBar 配置
3. 使用 base64 编码的图片
