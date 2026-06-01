# WildHerd

> 爬宠饲养管理助手（Flutter 移动端）+ B 站内容生产工具链

WildHerd 是"两栖"仓库：一个 Flutter 移动端应用 + 一套配套的 B 站内容生产工具链。两类工作流在文件系统上共存，但运行时完全分离——Flutter 应用（`lib/`）不依赖 `tools/`。

## 项目组成

- **Flutter 应用** — `lib/`、`android/`、`test/`、`assets/`
- **内容生产工具链** — `tools/`（review、video、publishing、collector）
- **文案与素材** — `docs/video/`（2332+ 篇脚本、prompts、reference）

## Flutter 应用

### 技术栈

- Flutter 3.x / Dart 3.x
- 状态管理：Riverpod（`flutter_riverpod`）
- 本地数据库：sqflite
- 图表：fl_chart
- 通知：flutter_local_notifications
- 定位 / 天气：geolocator / http

### 模块（features/）

| 模块 | 关键功能 |
|------|----------|
| `home/` | 爬宠列表、添加、详情、喂食/健康/成长记录、天气 |
| `breeding/` | 繁殖批次、蛋、苗子 |
| `habitat/` | 环境监测、对比、编辑 |
| `encyclopedia/` | 物种百科 + 物种图鉴 |
| `knowledge/` | 知识库 + 收藏 + 搜索 |
| `article/` | 科普文章 |
| `medical/` | 医疗记录 |
| `qa/` | 问答 |
| `reminders/` | 提醒列表 + 添加 |
| `shedding/` | 蜕皮记录 |
| `settings/` | 等级、调度设置 |

### 运行

```bash
flutter pub get
flutter run                # Android 调试
flutter test               # 跑 22 个测试
flutter build apk --release
```

## 内容生产工具链（tools/）

入口脚本、环境变量、依赖详见 [tools/README.md](tools/README.md)。

### 视频文案 Review

```bash
# 主入口：3 轮分维度 Review（含断点续传）
python tools/review/auto_review.py 5 20
```

### 视频生产与发布

```bash
python tools/video/video_workflow.py
python tools/publishing/bilibili_publisher.py upload
```

### 知识采集

```bash
python tools/collector.py
```

## 内容与文档

| 路径 | 内容 |
|------|------|
| `docs/video/scripts/` | 2332+ 篇视频脚本（按物种/主题分目录） |
| `docs/video/prompts/` | LLM 提示词模板 |
| `docs/video/reference/` | 参考资料（含 龟类生长、龟类价格） |
| `docs/knowledge/` | 物种养殖资料 |
| `docs/tutorials/` | Flutter 开发 / 功能文档 |
| `docs/automation/` | 审核清单、工作流手册 |
| [`docs/OPTIMIZATION_ROADMAP.md`](docs/OPTIMIZATION_ROADMAP.md) | 迭代路线图 |
| [`docs/MINI_PROGRAM_ROADMAP.md`](docs/MINI_PROGRAM_ROADMAP.md) | 微信小程序迁移计划 |

## 仓库规范

- **不提交**：`__pycache__/`、`.epub`、`.env`、API key
- **LFS 跟踪**：`.mp4`、`.png`、`.psd`、`.zip`、`.rar`、`.7z`、`.svg`、音频/视频/压缩包
- **单次提交按阶段**，便于回滚

## AI 协作

[`CLAUDE.md`](CLAUDE.md) 包含三栈（Flutter / 工具链 / 视频文案）的协作规范。

## 许可证

MIT
