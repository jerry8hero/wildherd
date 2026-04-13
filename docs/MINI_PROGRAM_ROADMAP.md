# WildHerd 微信小程序开发计划

> 从 Flutter App 到微信小程序的轻量化迁移方案

---

## 一、项目背景

### 1.1 现状分析

当前 WildHerd Flutter App 包含 **12 个功能模块**：

| 模块 | 复杂度 | 说明 |
|------|--------|------|
| home（首页/宠物管理） | 高 | 爬宠列表、添加、详情 |
| breeding（繁殖管理） | 高 | 批次、蛋、苗子管理 |
| habitat（饲养环境） | 高 | 环境监测、评分 |
| business（经营模块） | 中 | 财务、库存、客户 |
| encyclopedia（物种百科） | 中 | 物种信息浏览 |
| knowledge（知识库） | 中 | 知识文章、收藏 |
| medical（医疗健康） | 中 | 疾病、症状、急救 |
| qa（问答社区） | 中 | 问答互动 |
| article（知识文章） | 低 | 文章阅读 |
| companion（混养指南） | 低 | 兼容性查询 |
| settings（设置） | 低 | 用户偏好 |
| virtual_pet（虚拟养宠） | 低 | 游戏化功能 |

### 1.2 用户诉求

用户认为目前的 App 太重，希望用微信小程序来替换 App。

**核心诉求：**
- **轻量化** - 无需安装，扫码即用
- **降低门槛** - 适合简单高频场景
- **保留核心** - 爬宠记录、喂食提醒等

### 1.3 迁移目标

| 目标 | 说明 |
|------|------|
| 轻量化 | 小程序包体积 < 2MB |
| 快速启动 | 首屏加载 < 3秒 |
| 核心功能 | 保留宠物管理和记录功能 |
| 数据互通 | 支持从 Flutter App 迁移数据 |

---

## 二、技术选型

### 2.1 推荐方案：微信小程序 + 云开发

| 对比项 | 传统后端模式 | 云开发模式 |
|--------|------------|-----------|
| 账号资质 | 需要企业账号 | **个人即可** |
| 服务器成本 | 按月付费（几百/月） | **按量付费（免费额度充足）** |
| 开发周期 | 4-8周 | **2-4周** |
| 维护成本 | 高（服务器、域名、SSL） | **低（腾讯托管）** |
| 微信登录 | 需自行对接 | **自动支持** |

**云开发包含服务：**
- **云数据库** - MongoDB 兼容，JSON 文档存储
- **云函数** - Node.js 后端 API
- **云存储** - 图片等文件存储
- **微信登录** - 用户体系直接对接

### 2.2 技术栈

```
小程序端:
├── 框架: 微信小程序原生 (WXML/WXSS/JS)
├── UI组件: Vant Weapp (有赞组件库)
├── 状态管理: mobx-mini-program
└── 数据请求: wx.request / wx.cloud.callFunction

云端:
├── 云函数: Node.js 14+
├── 数据库: 云开发 MongoDB
└── 存储: 云开发存储
```

### 2.3 原 Flutter 技术栈参考

| 类别 | 技术 |
|------|------|
| 状态管理 | Riverpod |
| 本地存储 | SharedPreferences + JSON |
| 天气 API | Open-Meteo（免费） |
| 国际化 | flutter_localizations |

### 2.4 天气 API 选择

| API | 优势 | 劣势 | 推荐度 |
|-----|------|------|--------|
| **和风天气** | 国内访问稳定、免费额度充足（1000次/天）、有小程序 SDK | 需要注册账号 | ⭐⭐⭐⭐⭐ |
| Open-Meteo | 免费、无需注册 | 国内访问可能延迟/不稳定 | ⭐⭐⭐ |

> **建议：** 优先使用和风天气，注册地址：https://dev.qweather.com/

---

## 三、功能规划

### 3.1 v1.0 MVP（核心功能）

**目标：** 满足80%用户的日常使用场景

| 功能模块 | 优先级 | 复杂度 | 说明 |
|---------|--------|--------|------|
| 宠物列表 | P0 | 低 | 展示用户所有爬宠 |
| 添加宠物 | P0 | 低 | 填写基本信息 |
| 编辑/删除宠物 | P0 | 低 | 完整 CRUD |
| 宠物详情 | P0 | 低 | 查看宠物完整信息 |
| 喂食记录 | P0 | 低 | 记录喂食时间、食物类型 |
| 健康记录 | P0 | 低 | 体重、体长、状态记录 |
| 今日天气 | P1 | 中 | 温度、湿度、喂食建议 |
| 物种百科 | P1 | 中 | 只读浏览（不编辑） |

**v1.0 页面清单：**
```
pages/
├── index/            # 首页（宠物列表 + 天气）
├── pet-add/         # 添加宠物
├── pet-detail/      # 宠物详情
├── pet-edit/        # 编辑宠物
├── feeding/         # 喂食记录列表
├── feeding-add/     # 添加喂食记录
├── health/          # 健康记录列表
├── health-add/      # 添加健康记录
├── encyclopedia/     # 百科首页
├── species-detail/  # 物种详情
└── settings/        # 设置页面（预留语言切换入口）
```

### 3.2 v1.1（进阶功能）

**目标：** 满足进阶用户的繁殖和环境管理需求

| 功能模块 | 优先级 | 复杂度 | 说明 |
|---------|--------|--------|------|
| 繁殖批次管理 | P1 | 高 | 批次创建、状态追踪 |
| 蛋管理 | P1 | 高 | 照蛋、出壳记录 |
| 苗子档案 | P1 | 高 | 苗子成长记录 |
| 冬化监控 | P2 | 中 | 温度记录、提醒 |
| 饲养环境 | P1 | 高 | 环境参数记录 |
| 环境建议 | P2 | 中 | 基于标准给出建议 |
| 知识库 | P2 | 中 | 文章浏览、收藏 |
| 提醒推送 | P2 | 中 | 喂食提醒、孵化提醒 |
| 多语言 | P2 | 低 | 中/英切换 |

### 3.3 v2.0（完整功能）

**目标：** 覆盖所有 Flutter App 功能

| 功能模块 | 优先级 | 说明 |
|---------|--------|------|
| 经营模块 | P2 | 财务、库存、客户管理 |
| 医疗健康 | P2 | 疾病查询、症状检查 |
| QA社区 | P3 | 问答互动（需后端支持） |
| 虚拟养宠 | P3 | 简化版游戏化功能 |
| 混养指南 | P3 | 兼容性查询 |

### 3.4 不适合小程序的功能

| 功能 | 原因 | 建议方案 |
|-----|------|---------|
| 虚拟养宠（完整游戏） | 小程序性能限制 | 简化版或独立小程序 |
| 复杂数据分析报表 | 界面复杂不适合移动端 | 简化为关键指标卡片 |
| 高清图片上传/处理 | 存储和流量成本高 | 限制图片数量（≤9张）和大小（≤2MB） |
| 离线模式 | 云开发天然要求在线 | 仅做弱网提示 |

---

## 四、数据设计

### 4.1 云数据库集合

```javascript
// 用户集合 - 微信用户自动创建
{
  "_id": "wx_openid_xxx",
  "nickName": "用户昵称",
  "avatarUrl": "头像URL",
  "level": "beginner",      // beginner / intermediate / advanced
  "language": "zh",          // zh / en
  "createdAt": Date,
  "updatedAt": Date
}

// 爬宠集合
{
  "_id": "uuid_xxx",
  "userId": "wx_openid_xxx",  // 用户隔离
  "name": "小青",
  "species": "corn_snake",
  "speciesChinese": "玉米蛇",
  "gender": "female",
  "birthDate": "2023-05-01",
  "weight": 150.5,
  "length": 80.0,
  "imageUrl": "cloud://xxx.jpg",  // 云存储路径
  "acquisitionDate": "2023-01-01",
  "breedingStatus": "available",
  "notes": "",
  "createdAt": Date,
  "updatedAt": Date
}

// 喂食记录集合
{
  "_id": "uuid_xxx",
  "userId": "wx_openid_xxx",
  "reptileId": "reptile_uuid",
  "feedingTime": Date,
  "foodType": "mouse",
  "foodAmount": 15.0,
  "notes": "",
  "createdAt": Date
}

// 健康记录集合
{
  "_id": "uuid_xxx",
  "userId": "wx_openid_xxx",
  "reptileId": "reptile_uuid",
  "recordDate": Date,
  "weight": 155.0,
  "length": 82.0,
  "status": "normal",       // normal / abnormal
  "defecation": "normal",   // normal / abnormal / constipated
  "notes": "",
  "createdAt": Date
}

// 物种百科集合 - 预置数据
{
  "_id": "corn_snake",
  "nameChinese": "玉米蛇",
  "nameEnglish": "Corn Snake",
  "category": "snake",
  "difficulty": 1,          // 1-5
  "lifespan": 15,           // 年
  "tempDay": 28,            // 白天温度
  "tempNight": 24,          // 夜晚温度
  "humidity": 50,           // 湿度%
  "diet": "mouse",
  "size": "100-150cm",
  "behavior": "温和",
  "description": "...",
  "careTips": [...]
}
```

### 4.2 云函数设计

```javascript
// cloudfunctions/reptile/index.js
// 爬宠管理云函数

const cloud = require('wx-server-sdk')
cloud.init({ env: cloud.DYNAMIC_CURRENT_ENV })

const db = cloud.database()

// 统一响应格式
const response = (success, data, message) => ({
  success,
  data,
  message
})

exports.main = async (event, context) => {
  const { action, data } = event

  try {
    switch (action) {
      case 'getAll':
        // 获取当前用户所有爬宠
        const reptiles = await db.collection('reptiles')
          .where({ userId: cloud.getWXContext().OPENID })
          .orderBy('updatedAt', 'desc')
          .get()
        return response(true, reptiles.data)

      case 'add':
        // 添加爬宠
        data.userId = cloud.getWXContext().OPENID
        data.createdAt = new Date()
        data.updatedAt = new Date()
        await db.collection('reptiles').add({ data })
        return response(true, null, '添加成功')

      case 'update':
        // 更新爬宠
        const { _id, ...updateData } = data
        updateData.updatedAt = new Date()
        await db.collection('reptiles')
          .doc(_id)
          .update({ data: updateData })
        return response(true, null, '更新成功')

      case 'delete':
        // 删除爬宠
        await db.collection('reptiles').doc(data._id).remove()
        return response(true, null, '删除成功')

      default:
        return response(false, null, '未知操作')
    }
  } catch (e) {
    return response(false, null, e.message)
  }
}
```

---

## 五、数据迁移

### 5.1 迁移流程

```
┌─────────────────────────────────────────────────────────────┐
│                      Flutter App                            │
│                                                             │
│  设置页面                                                   │
│    └── [导出数据] ──→ 生成 reptiles_backup.json           │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                              │
                              │ 用户操作
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    微信小程序                                │
│                                                             │
│  登录页                                                    │
│    └── [检测到导入文件] ──→ 弹出迁移引导                    │
│    └── [确认迁移] ──→ 解析 JSON ──→ 写入云数据库           │
│    └── [迁移完成] ──→ 跳转首页                            │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 5.2 迁移工具开发

**Flutter App 端：**
- 在「设置」页面添加「导出数据」按钮
- 将 SharedPreferences 中的所有数据导出为 JSON 文件
- 支持选择导出的数据类型（宠物、记录等）

**小程序端：**
- 登录后检测是否有导入文件
- 显示待迁移数据预览
- 用户确认后批量写入云数据库
- 迁移完成后删除本地文件

### 5.3 迁移数据结构

```json
{
  "version": "1.0",
  "exportTime": "2026-04-12T10:00:00Z",
  "data": {
    "reptiles": [...],
    "feedingRecords": [...],
    "healthRecords": [...],
    "breedingBatches": [...],
    "habitats": [...]
  }
}
```

---

## 六、开发阶段

> **总工期预估：** MVP 阶段 4-5 周（不含审核上线时间 1-2 周）

### Day 0：准备日（0.5 天）

**目标：** 确保开发环境就绪

**交付物：**
- [ ] 微信小程序账号注册（需实名认证）
- [ ] 下载安装微信开发者工具
- [ ] 和风天气开发者账号注册
- [ ] 熟悉云开发控制台

### 阶段一：基础建设（第 1-1.5 周）

**目标：** 完成小程序框架搭建和云开发环境配置

**交付物：**
- [ ] 微信小程序账号注册
- [ ] 开通云开发服务
- [ ] 项目目录结构创建
- [ ] Vant Weapp 组件库按需引入（注意包体积控制）
- [ ] 云数据库集合创建（reptiles, feeding_records, health_records, species）
- [ ] 云函数基础模板

**包体积控制策略：**
- Vant Weapp 按需引入，不全量安装
- 图片资源压缩后上传
- 定期使用 `微信开发者工具 → 详情 → 文件大小` 检查

**项目目录结构：**
```
wildherd-mini-program/
├── cloudfunctions/          # 云函数
│   ├── login/              # 微信登录
│   ├── reptile/            # 爬宠 CRUD
│   ├── feeding/            # 喂食记录
│   ├── health/             # 健康记录
│   ├── weather/            # 天气查询
│   └── species/            # 物种百科
│
├── miniprogram/            # 小程序主体
│   ├── pages/
│   │   ├── index/          # 首页
│   │   ├── pet-list/       # 宠物列表
│   │   ├── pet-add/        # 添加宠物
│   │   ├── pet-detail/     # 宠物详情
│   │   ├── pet-edit/       # 编辑宠物
│   │   ├── feeding/        # 喂食记录
│   │   ├── health/         # 健康记录
│   │   ├── encyclopedia/    # 百科首页
│   │   ├── species-detail/ # 物种详情
│   │   └── settings/       # 设置
│   │
│   ├── components/         # 公共组件
│   │   ├── pet-card/       # 宠物卡片
│   │   ├── record-item/    # 记录项
│   │   └── weather-card/   # 天气卡片
│   │
│   ├── services/           # API 服务
│   │   ├── api.js          # 云函数调用封装
│   │   ├── reptile.js      # 爬宠 API
│   │   ├── feeding.js      # 喂食 API
│   │   └── weather.js      # 天气 API
│   │
│   ├── stores/             # 状态管理
│   │   ├── reptileStore.js
│   │   ├── feedingStore.js
│   │   └── userStore.js
│   │
│   ├── locale/             # 国际化
│   │   ├── zh.json
│   │   └── en.json
│   │
│   └── utils/              # 工具函数
│       ├── date.js
│       └── format.js
│
├── project.config.json
└── README.md
```

### 阶段二：核心功能（第 2-4 周）

**目标：** 完成 v1.0 MVP 所有功能

**交付物：**
- [ ] 用户登录（微信一键登录 + 获取 OpenID）
- [ ] 爬宠管理（列表、添加、编辑、删除）
- [ ] 喂食记录（列表、添加、删除）
- [ ] 健康记录（列表、添加、删除）
- [ ] 首页展示（宠物卡片、天气、快速入口）
- [ ] 天气信息（和风天气 API）
- [ ] 物种百科浏览（只读）
- [ ] 设置页面（语言切换入口，为 v1.1 多语言做准备）

### 阶段三：测试与优化（第 4-4.5 周）

**目标：** 修复问题，优化体验

**交付物：**
- [ ] 功能测试（边界条件、异常处理）
- [ ] 性能优化（首屏加载、接口响应）
- [ ] UI 细节调整（间距、字体、动画）
- [ ] 用户引导优化（新用户引导）
- [ ] 包体积检查（确保 < 2MB）

### 阶段四：审核与上线（第 5 周）

**目标：** 正式发布

> ⚠️ 微信审核需要 1-7 天，建议预留 2 周缓冲

**交付物：**
- [ ] 小程序码生成
- [ ] 审核材料准备（截图、说明）
- [ ] 提交审核
- [ ] 发布上线
- [ ] Flutter App 添加跳转提示

### 阶段五：数据迁移工具（第 5.5-6 周）

**目标：** 支持从 Flutter App 迁移数据

**交付物：**
- [ ] Flutter App 端数据导出功能
- [ ] 小程序端数据导入功能
- [ ] 迁移流程测试

---

## 七、实施计划

### Day 0：准备日（0.5 天）

| 任务 | 说明 |
|------|------|
| 注册微信小程序账号 | https://mp.weixin.qq.com/（需微信实名认证） |
| 下载开发者工具 | 微信开发者工具 |
| 注册和风天气账号 | https://dev.qweather.com/ |
| 熟悉云开发控制台 | 数据库、存储、云函数 |

### Day 1-3：基础建设

| 任务 | 说明 |
|------|------|
| 初始化小程序项目 | 创建项目，配置 AppID |
| 开通云开发服务 | 控制台 → 云开发 |
| 引入 Vant Weapp | 按需引入（button、field、card、cell） |
| 创建云数据库集合 | reptiles, feeding_records, health_records, species |
| 部署云函数模板 | login 获取 OpenID |

### Day 4-7：云函数开发

| 云函数 | 功能 |
|--------|------|
| login | 微信登录，获取 OpenID |
| reptile | 爬宠 CRUD |
| feeding | 喂食记录 CRUD |
| health | 健康记录 CRUD |
| weather | 天气查询（和风天气 API） |

### Day 8-18：前端开发

| 页面 | 功能 |
|------|------|
| index | 首页（宠物列表 + 天气 + 快捷入口） |
| pet-add/edit | 添加/编辑宠物表单 |
| pet-detail | 宠物详情（基础信息 + 记录） |
| feeding | 喂食记录列表 + 添加 |
| health | 健康记录列表 + 添加 |
| encyclopedia | 百科分类 + 物种列表 |
| species-detail | 物种详情（只读） |
| settings | 设置页面（预留语言切换入口） |

### Day 19-20：测试与优化

1. 功能测试
2. 修复 Bug
3. 包体积检查
4. 性能优化

### Day 21-22：审核材料准备

| 任务 | 说明 |
|------|------|
| 准备截图 | 首页、宠物详情、喂食记录等 |
| 编写说明 | 功能介绍、使用场景 |
| 提交审核 | 预留 2 周审核时间 |

### Day 23-25：数据迁移开发

| 端 | 任务 |
|----|------|
| Flutter App | 添加「导出数据」功能 |
| 小程序 | 添加「导入数据」功能 |
| 测试 | 完整迁移流程测试 |

---

## 八、风险与应对

### 8.1 技术风险

| 风险 | 概率 | 影响 | 应对方案 |
|-----|-----|-----|---------|
| 云开发免费额度不够用 | 低 | 中 | 预估用量，设置预算告警 |
| 并发连接数限制 | 中 | 中 | 使用云数据库而非云函数直连 |
| 图片上传失败 | 中 | 低 | 限制图片大小（≤2MB），提供重试机制 |
| 接口超时 | 低 | 低 | 添加 loading 状态和超时提示 |
| 包体积超限（2MB） | 中 | 中 | 按需引入组件，压缩图片 |
| 天气 API 不可用 | 低 | 中 | 和风天气作为主用，有备选缓存机制 |

### 8.2 用户体验风险

| 风险 | 影响 | 应对方案 |
|-----|-----|---------|
| 小程序包体积超限（2MB） | 中 | 压缩图片，按需加载页面 |
| 首次加载慢 | 中 | 使用骨架屏，分页加载 |
| 功能比 App 少 | 高 | 明确告知这是轻量版 |
| **用户拒绝微信授权** | 高 | 引导用户了解授权必要性，无授权则无法使用核心功能 |
| 新用户不知如何操作 | 中 | 添加新用户引导（首次打开 App 时） |

### 8.3 数据迁移风险

| 风险 | 应对方案 |
|-----|---------|
| 迁移过程中数据丢失 | 分批次迁移，保留原数据 |
| 用户不会操作迁移 | 提供详细引导教程 |
| 迁移时间过长 | 支持后台迁移 |

### 8.4 运维风险

| 风险 | 应对方案 |
|-----|---------|
| 云开发账单超出预期 | 设置预算告警 |
| 数据库性能问题 | 合理设计索引，定期清理 |
| 微信审核被拒 | 提前了解审核规范 |

---

## 九、后续迭代

### v1.1 功能（预计 2 周）

- 繁殖批次管理（批次列表、添加、状态更新）
- 蛋管理（照蛋记录、出壳记录）
- 苗子档案（成长记录）
- 冬化监控（温度记录、提醒）
- 饲养环境（环境参数记录）
- 环境建议（基于物种标准）
- **多语言支持**（中/英切换）

### v2.0 功能（预计 4 周）

- 经营模块（财务、库存、客户管理）
- 医疗健康（疾病库、症状检查）
- 知识库（文章浏览、收藏）
- QA 社区（问答互动）
- 虚拟养宠（简化版）
- 混养指南

---

## 十、Flutter App 协作

### 10.1 App 端改造

在 Flutter App 中添加以下功能：

```dart
// 设置页面添加入口
ListTile(
  title: Text('导出数据'),
  subtitle: Text('迁移到小程序'),
  trailing: Icon(Icons.upload),
  onTap: () => _exportData(),
)
```

### 10.2 App 端导出功能

```dart
Future<void> _exportData() async {
  // 1. 读取所有数据
  final reptiles = await ReptileRepository.getAllReptiles();
  final feedingRecords = await RecordRepository.getFeedingRecords();
  final healthRecords = await RecordRepository.getHealthRecords();

  // 2. 生成 JSON
  final exportData = {
    'version': '1.0',
    'exportTime': DateTime.now().toIso8601String(),
    'data': {
      'reptiles': reptiles,
      'feedingRecords': feedingRecords,
      'healthRecords': healthRecords,
    },
  };

  // 3. 保存为文件
  final file = File('reptiles_backup.json');
  await file.writeAsString(jsonEncode(exportData));

  // 4. 分享文件
  await Share.shareXFiles([XFile(file.path)]);
}
```

### 10.3 小程序端导入

```javascript
// 在 app.js 的 onLaunch 中检测
onLaunch: async function() {
  // 检查是否有导入文件
  const fs = wx.getFileSystemManager();
  try {
    const fileContent = fs.readFileSync(`${wx.env.USER_DATA_PATH}/reptiles_backup.json`);
    const data = JSON.parse(fileContent);

    // 弹出迁移确认
    wx.showModal({
      title: '检测到导入文件',
      content: `是否迁移 ${data.data.reptiles.length} 只爬宠？`,
      success: async (res) => {
        if (res.confirm) {
          await this.migrateData(data);
        }
      }
    });
  } catch (e) {
    // 文件不存在，跳过
  }
}
```

---

## 十一、关键参考文件

Flutter App 中需要参考的源文件：

| 文件路径 | 用途 |
|---------|------|
| `lib/data/models/reptile.dart` | 爬宠数据模型 |
| `lib/data/models/record.dart` | 喂食/健康记录模型 |
| `lib/data/local/database_helper.dart` | 数据存储实现 |
| `lib/features/home/home_screen.dart` | 首页 UI 参考 |
| `lib/data/services/weather_service.dart` | 天气服务 API |
| `lib/app/theme.dart` | 主题色彩参考 |
| `docs/OPTIMIZATION_ROADMAP.md` | App 后续规划参考 |

---

## 十二、文档信息

| 项目 | 内容 |
|------|------|
| 创建日期 | 2026-04-12 |
| 更新时间 | 2026-04-13 |
| 负责人 | - |
| 版本 | v1.1 |
| 状态 | 规划中 |
| 开发周期 | MVP 4-6 周（含审核），数据迁移 0.5 周 |

---

*本文档为 WildHerd 微信小程序迁移计划，如有疑问请联系开发者。*
