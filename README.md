# WildHerd - 爬宠助手

一款专为爬宠爱好者打造的移动应用，帮助你记录爬宠的日常生活、健康状况，同时提供丰富的爬宠知识百科和社区交流功能。

## 功能概览

### 🏠 首页
- 欢迎卡片，展示你的爬宠数量
- 爬宠快捷入口
- 快捷功能按钮（喂食记录、健康记录、成长相册）
- 日常提醒（湿度、温度等）

### 🦎 爬宠管理
- 添加爬宠档案（名字、种类、性别、出生日期、体重）
- 支持多种爬宠类型：蛇类、蜥蜴类、龟类、守宫类、两栖类
- 查看爬宠详情
- 删除爬宠

### 📚 知识百科
- 分类浏览爬宠种类：蛇类、蜥蜴、龟类、守宫、两栖
- 物种详情页：学名、习性、饲养难度、寿命、环境要求
- 内置常见爬宠数据：
  - 玉米蛇
  - 豹纹守宫
  - 绿鬣蜥
  - 红耳龟
  - 鬃狮蜥
  - 球蟒

### 👥 社区
- 浏览动态
- 发布爬宠日常
- 点赞、评论互动

## 技术架构

### 技术栈
- **框架**: Flutter 3.24.0
- **语言**: Dart 3.5.0
- **状态管理**: Provider
- **本地数据库**: SQLite (sqflite)
- **UI**: Material Design 3

### 项目结构
```
lib/
├── main.dart                 # 应用入口
├── app/
│   ├── app.dart              # 应用配置
│   └── theme.dart            # 主题配置
├── core/
│   ├── constants/            # 常量
│   ├── utils/                # 工具类
│   └── services/             # 服务层
├── data/
│   ├── models/               # 数据模型
│   ├── repositories/        # 数据仓库
│   └── local/                # 本地存储
├── features/
│   ├── home/                 # 首页
│   ├── pets/                 # 爬宠管理
│   ├── encyclopedia/        # 知识百科
│   └── community/            # 社区
└── widgets/                  # 通用组件
```

## 安装说明

### 环境要求
- Flutter SDK 3.24.0+
- Dart SDK 3.5.0+
- Android SDK (API 21+)
- iOS 12.0+

### 安装步骤

#### 1. 克隆项目
```bash
git clone <repository-url>
cd wildherd
```

#### 2. 安装依赖
```bash
flutter pub get
```

#### 3. 运行项目
```bash
# 运行调试版本
flutter run

# 构建 Android APK
flutter build apk --debug

# 构建 iOS
flutter build ios
```

#### 4. 发布版本
```bash
# Android release
flutter build apk --release

# iOS release
flutter build ios --release
```

## 数据模型

### 爬宠 (Reptile)
| 字段 | 类型 | 说明 |
|------|------|------|
| id | String | 唯一标识 |
| name | String | 名字 |
| species | String | 种类英文标识 |
| speciesChinese | String | 中文名 |
| gender | String | 性别 |
| birthDate | DateTime | 出生日期 |
| weight | double | 体重(g) |
| length | double | 体长(cm) |
| imagePath | String | 头像路径 |

### 记录 (Records)
- **喂食记录**: 时间、食物类型、食物量
- **健康记录**: 体重、体长、状态、排便情况
- **成长相册**: 照片、描述、日期

## 使用指南

### 添加第一只爬宠
1. 打开应用，进入"爬宠"页面
2. 点击右下角 "+" 按钮
3. 填写爬宠信息（名字、种类、性别等）
4. 点击"添加"保存

### 记录喂食
1. 在首页点击"喂食记录"
2. 选择爬宠
3. 填写喂食信息

### 查看百科
1. 进入"百科"页面
2. 选择爬宠类别（蛇类、蜥蜴等）
3. 点击物种查看详情

### 发布动态
1. 进入"社区"页面
2. 点击右下角 "+" 按钮
3. 选择爬宠种类（可选）
4. 输入内容
5. 点击"发布"

## 后续开发计划

- [ ] 喂食提醒功能
- [ ] 健康数据图表展示
- [ ] 云端数据同步
- [ ] 用户登录系统
- [ ] 消息通知
- [ ] 更多爬宠种类数据

## 许可证

MIT License

## 贡献

欢迎提交 Issue 和 Pull Request！
