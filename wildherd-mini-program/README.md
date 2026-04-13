# WildHerd 微信小程序

> 从 Flutter App 到微信小程序的轻量化迁移方案

## 项目结构

```
wildherd-mini-program/
├── cloudfunctions/          # 云函数
│   ├── login/              # 微信登录
│   ├── reptile/            # 爬宠 CRUD
│   ├── feeding/            # 喂食记录
│   ├── health/             # 健康记录
│   ├── weather/            # 天气查询
│   ├── species/            # 物种百科
│   └── init-db/            # 数据库初始化
│
├── miniprogram/            # 小程序主体
│   ├── pages/
│   │   ├── index/          # 首页
│   │   ├── pet-add/        # 添加宠物
│   │   ├── pet-detail/     # 宠物详情
│   │   ├── pet-edit/       # 编辑宠物
│   │   ├── feeding/        # 喂食记录
│   │   ├── health/         # 健康记录
│   │   ├── encyclopedia/   # 百科首页
│   │   ├── species-detail/ # 物种详情
│   │   └── settings/       # 设置
│   │
│   ├── components/         # 公共组件
│   │   ├── pet-card/       # 宠物卡片
│   │   ├── weather-card/   # 天气卡片
│   │   └── record-item/    # 记录项
│   │
│   ├── services/           # API 服务
│   ├── utils/              # 工具函数
│   ├── locale/             # 国际化（中/英）
│   └── assets/             # 静态资源
│
├── database/               # 数据库相关
│   └── species_seed.json   # 物种数据种子
│
├── project.config.json
└── README.md
```

## 快速开始

### 1. 环境准备

1. 注册微信小程序账号：https://mp.weixin.qq.com/
2. 开通云开发服务（控制台 → 云开发）
3. 下载微信开发者工具：https://developers.weixin.qq.com/miniprogram/dev/devtools/download.html
4. 注册和风天气账号：https://dev.qweather.com/

### 2. 项目配置

1. 克隆项目后，在 `微信开发者工具` 中导入项目
2. 修改 `project.config.json` 中的 `appid` 为你的小程序 AppID
3. 修改 `cloudfunctions/weather/index.js` 中的 `HEFENG_KEY` 为你的和风天气 Key

### 3. 安装 Vant Weapp

在项目根目录执行：

```bash
# 初始化 npm（如果还没有 package.json）
npm init -y

# 安装 Vant Weapp
npm i vant-weapp -S --production
```

然后在微信开发者工具中：
1. 点击「工具」→「构建 npm」
2. 勾选「使用 npm 模块」

### 4. 部署云函数

在微信开发者工具中：
1. 右键点击 `cloudfunctions` 文件夹
2. 选择「上传并部署」
3. 依次部署每个云函数（建议选择「云端安装依赖」）

### 5. 创建云数据库集合

在云开发控制台中创建以下集合（权限设置见下方）：

| 集合名 | 用途 | 权限配置 |
|-------|------|---------|
| users | 用户信息 | 所有用户可读，创建者可写 |
| reptiles | 爬宠数据 | 所有用户可读，创建者可写 |
| feeding_records | 喂食记录 | 所有用户可读，创建者可写 |
| health_records | 健康记录 | 所有用户可读，创建者可写 |
| species | 物种百科 | 所有用户可读 |

### 6. 初始化物种数据

**方式一：使用 init-db 云函数**
1. 部署 `cloudfunctions/init-db/` 云函数
2. 在云开发控制台调用该云函数
3. 或在小程序中临时添加一个按钮调用

**方式二：手动导入**
1. 打开 `database/species_seed.json`
2. 在云开发控制台的 `species` 集合中导入

## 功能特性

### v1.0 MVP ✅
- ✅ 用户登录（微信一键登录）
- ✅ 爬宠管理（列表、添加、编辑、删除）
- ✅ 喂食记录（列表、添加、删除）
- ✅ 健康记录（列表、添加、删除）
- ✅ 天气信息（和风天气）
- ✅ 物种百科（分类浏览、详情查看）
- ✅ 数据迁移（支持从 Flutter App 导入）

### v1.1（计划中）
- ⬜ 繁殖批次管理
- ⬜ 蛋/苗子管理
- ⬜ 多语言支持（中/英）
- ⬜ 提醒推送

## 技术栈

| 类别 | 技术 |
|------|------|
| 框架 | 微信小程序原生 (WXML/WXSS/JS) |
| UI组件 | Vant Weapp |
| 云开发 | 腾讯云开发 |
| 天气API | 和风天气 |

## 数据库集合设计

### users 集合
```json
{
  "_id": "openid_xxx",
  "nickName": "用户昵称",
  "avatarUrl": "头像URL",
  "level": "beginner",
  "language": "zh",
  "createdAt": "创建时间"
}
```

### reptiles 集合
```json
{
  "_id": "uuid",
  "userId": "openid",
  "name": "小青",
  "species": "corn_snake",
  "speciesChinese": "玉米蛇",
  "gender": "female",
  "birthDate": "2023-05-01",
  "weight": 150.5,
  "length": 80.0,
  "imageUrl": "cloud://xxx.jpg",
  "breedingStatus": "available",
  "notes": "",
  "createdAt": "创建时间",
  "updatedAt": "更新时间"
}
```

### feeding_records 集合
```json
{
  "_id": "uuid",
  "userId": "openid",
  "reptileId": "reptile_uuid",
  "feedingTime": "2024-01-15",
  "foodType": "mouse",
  "foodAmount": 15.0,
  "notes": "",
  "createdAt": "创建时间"
}
```

### health_records 集合
```json
{
  "_id": "uuid",
  "userId": "openid",
  "reptileId": "reptile_uuid",
  "recordDate": "2024-01-15",
  "weight": 155.0,
  "length": 82.0,
  "status": "normal",
  "defecation": "normal",
  "notes": "",
  "createdAt": "创建时间"
}
```

### species 集合（预置数据）
```json
{
  "_id": "corn_snake",
  "nameChinese": "玉米蛇",
  "nameEnglish": "Corn Snake",
  "category": "snake",
  "difficulty": 1,
  "lifespan": 15,
  "tempDay": 28,
  "tempNight": 24,
  "humidity": 50,
  "diet": "老鼠",
  "size": "100-150cm",
  "behavior": "温和",
  "description": "...",
  "careTips": ["...", "..."]
}
```

## 注意事项

1. **包体积控制**：微信小程序包体积限制 2MB，请按需引入 Vant Weapp 组件
2. **图片上传**：限制图片大小 ≤ 2MB，上传到云存储
3. **用户隔离**：所有数据通过 OpenID 进行用户隔离，确保数据安全
4. **数据迁移**：支持从 Flutter App 导出 JSON 文件并导入到小程序
5. **和风天气 Key**：必须替换为有效的 Key，否则天气功能不可用

## API 调用方式

```javascript
const reptileService = require('../../services/reptile.js')

// 获取所有爬宠
const res = await reptileService.getAll()
if (res.success) {
  console.log(res.data)
}

// 添加爬宠
const addRes = await reptileService.add({
  name: '小青',
  species: 'corn_snake',
  speciesChinese: '玉米蛇',
  gender: 'female'
})
```

## 常见问题

### Q: 云函数调用失败
A: 检查云函数是否已部署，尝试重新部署并勾选「云端安装依赖」

### Q: 数据库权限不足
A: 在云开发控制台调整集合权限为「所有用户可读，创建者可写」

### Q: 天气显示不出来
A: 确认已替换有效的和风天气 Key，且用户已授权位置权限

### Q: Vant 组件不显示
A: 执行「工具」→「构建 npm」，确保已安装 vant-weapp

## License

MIT
