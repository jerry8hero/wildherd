# 视频脚本管理工具使用指南

> 📚 管理 2400+ 个视频脚本的完整工具集

---

## 目录

- [概述](#概述)
- [环境准备](#环境准备)
- [快速开始](#快速开始)
- [工具详解](#工具详解)
  - [1. 索引生成器](#1-索引生成器-scripts_indexerpy)
  - [2. 搜索工具](#2-搜索工具-scripts_searchpy)
  - [3. 批量管理工具](#3-批量管理工具-scripts_managerpy)
- [文件类型与命名规范](#文件类型与命名规范)
- [索引数据结构](#索引数据结构)
- [工作流场景](#工作流场景)
- [常见问题](#常见问题)
- [最佳实践](#最佳实践)

---

## 概述

本工具集用于管理 `docs/video/scripts/` 目录下的视频脚本，解决以下问题：

| 问题 | 解决方案 |
|------|----------|
| 2400+ 文件难以检索 | 统一索引 + 多维度搜索 |
| 发布状态分散 | 集中管理状态和链接 |
| 文件命名混乱 | 批量重命名工具 |
| 无法快速备份 | 按物种导出功能 |

### 工具清单

```
tools/
├── scripts_indexer.py      # 索引生成器（扫描 → JSON）
├── scripts_search.py       # 搜索工具（多维度查询）
├── scripts_manager.py      # 批量管理（状态/重命名/导出）
└── SCRIPTS_MANAGER_GUIDE.md # 本文档
```

### 脚本目录结构

```
docs/video/scripts/
├── index.json              ← 自动生成的索引
│
├── 草龟/                   # 普通物种目录
│   ├── 01-养草龟需要准备什么.md           # 主脚本
│   ├── 01-B站发布内容.md                  # B站发布内容
│   ├── 01-养草龟需要准备什么_剪映版.md    # 剪映版
│   └── ...
│
├── 冷到你唔信/             # 特殊多层结构
│   ├── 第一册-哺乳动物/
│   │   ├── 001-大熊猫/
│   │   │   ├── 001-大熊猫_视频文案.md
│   │   │   └── 001-大熊猫_视频文案_粤语.md
│   │   └── ...
│   ├── 第二册-两栖动物/
│   │   └── ...
│   └── 全七册/_archive/    # 归档备份（忽略）
│
└── 其他物种/
    └── ...
```

---

## 环境准备

### 系统要求

- Python 3.8+
- 无需额外依赖（仅使用标准库）

### 验证安装

```bash
# 检查 Python 版本
python3 --version

# 验证工具可执行
python3 tools/scripts_indexer.py --help
python3 tools/scripts_search.py --help
python3 tools/scripts_manager.py --help
```

---

## 快速开始

### 第一步：生成索引

```bash
python3 tools/scripts_indexer.py
```

**输出示例：**
```
📂 扫描目录: /path/to/docs/video/scripts
  📁 草龟...
  📁 巴西龟...
  📁 冷到你唔信 (多层结构)...
    📕 第一册-哺乳动物...
    📕 第二册-两栖动物...
    ...

✅ 索引已生成: docs/video/scripts/index.json
   总文件数: 1426
   物种数: 26
   文件类型分布:
     - script: 964
     - bilibili_publish: 415
     - jianying: 37
```

### 第二步：搜索脚本

```bash
# 搜索草龟所有脚本
python3 tools/scripts_search.py -s 草龟

# 搜索包含"繁殖"关键词的脚本
python3 tools/scripts_search.py -k 繁殖

# 查看统计信息
python3 tools/scripts_search.py --stats
```

### 第三步：管理脚本

```bash
# 查看详细报告
python3 tools/scripts_manager.py report

# 更新发布状态
python3 tools/scripts_manager.py status 草龟 1 published --url https://www.bilibili.com/video/BV1xxxxxx
```

---

## 工具详解

### 1. 索引生成器 (`scripts_indexer.py`)

**功能：** 扫描脚本目录，生成统一的 JSON 索引文件

**使用方法：**

```bash
# 基本用法
python3 tools/scripts_indexer.py
```

**输出文件：** `docs/video/scripts/index.json`

**何时运行：**

| 场景 | 是否需要 |
|------|----------|
| 首次使用 | ✅ 必须 |
| 添加新脚本 | ✅ 必须 |
| 删除脚本 | ✅ 必须 |
| 重命名脚本 | ✅ 必须 |
| 只是搜索/查询 | ❌ 不需要 |

**工作原理：**

1. 扫描 `docs/video/scripts/` 下所有 `.md` 文件
2. 解析文件名，提取序号、标题、类型
3. 计算字数，提取标签
4. 生成 `index.json` 索引文件

---

### 2. 搜索工具 (`scripts_search.py`)

**功能：** 基于索引进行多维度搜索

**参数说明：**

| 参数 | 缩写 | 说明 | 示例 |
|------|------|------|------|
| `--species` | `-s` | 物种名称（模糊匹配） | `-s 草龟` |
| `--keyword` | `-k` | 关键词（搜索标题和路径） | `-k 繁殖` |
| `--type` | `-t` | 文件类型 | `-t script` |
| `--volume` | `-v` | 册子名称（仅冷到你唔信） | `-v 第五册` |
| `--min` | | 最小集数 | `--min 1` |
| `--max` | | 最大集数 | `--max 10` |
| `--limit` | `-l` | 结果数量限制（默认 20） | `-l 50` |
| `--stats` | | 显示统计信息 | `--stats` |
| `--verbose` | | 显示详细信息 | `--verbose` |

**使用示例：**

```bash
# 基础搜索
python3 tools/scripts_search.py -s 草龟                    # 搜索草龟
python3 tools/scripts_search.py -k 繁殖                    # 搜索"繁殖"
python3 tools/scripts_search.py -t bilibili_publish        # 搜索B站发布内容

# 组合搜索
python3 tools/scripts_search.py -s 草龟 -k 繁殖            # 草龟 + 繁殖
python3 tools/scripts_search.py -s 草龟 --min 1 --max 10  # 草龟 1-10 集
python3 tools/scripts_search.py -s 冷到你唔信 -v 第五册    # 冷到你唔信第五册

# 统计查询
python3 tools/scripts_search.py --stats                    # 总体统计
python3 tools/scripts_search.py --stats -s 草龟            # 草龟统计

# 详细输出
python3 tools/scripts_search.py -s 草龟 --verbose          # 显示路径、修改时间、标签
```

**输出示例：**

```
找到 10 个结果:

----------------------------------------------------------------------------------------------------
物种         册子           集数     类型              标题                                  字数
----------------------------------------------------------------------------------------------------
草龟         -            1      script          养草龟需要准备什么                           1022
草龟         -            2      script          草龟到家后怎么养                            1542
草龟         -            3      script          草龟吃什么                               1404
...
----------------------------------------------------------------------------------------------------
```

**文件类型标识：**

| 标识 | 说明 |
|------|------|
| `script` | 主脚本（视频文案） |
| `bilibili_publish` | B站发布内容 |
| `jianying` | 剪映版本 |
| `xiaohongshu` | 小红书发布内容 |
| `cover_prompt` | 封面生图提示词 |

---

### 3. 批量管理工具 (`scripts_manager.py`)

**功能：** 批量操作、状态管理、数据导出

**子命令：**

| 命令 | 说明 | 示例 |
|------|------|------|
| `report` | 显示统计报告 | `python3 tools/scripts_manager.py report` |
| `list` | 列出所有物种 | `python3 tools/scripts_manager.py list` |
| `status` | 更新脚本状态 | `python3 tools/scripts_manager.py status 草龟 1 published` |
| `rename` | 批量重命名 | `python3 tools/scripts_manager.py rename 草龟` |
| `export` | 导出物种脚本 | `python3 tools/scripts_manager.py export 草龟` |

#### 3.1 查看报告

```bash
python3 tools/scripts_manager.py report
```

**输出：**
```
============================================================
📊 视频脚本统计报告
============================================================

📁 总体统计:
   总文件数: 1426
   物种数: 26

📂 文件类型分布:
   - bilibili_publish: 415
   - script: 964
   - jianying: 37

📈 物种排行 (Top 15):
    1. 冷到你唔信: 1093 个文件
    2. 草龟: 76 个文件
    3. 鳄龟: 50 个文件
    ...
============================================================
```

#### 3.2 列出所有物种

```bash
python3 tools/scripts_manager.py list
```

#### 3.3 更新脚本状态

```bash
# 基本用法
python3 tools/scripts_manager.py status <物种> <集数> <状态>

# 带 B 站链接
python3 tools/scripts_manager.py status <物种> <集数> <状态> --url <链接>
```

**状态值：**

| 状态 | 说明 |
|------|------|
| `draft` | 草稿（默认） |
| `in_progress` | 制作中 |
| `published` | 已发布 |
| `deprecated` | 已废弃 |

**示例：**

```bash
# 标记为已发布
python3 tools/scripts_manager.py status 草龟 1 published

# 标记为已发布并添加链接
python3 tools/scripts_manager.py status 草龟 1 published --url https://www.bilibili.com/video/BV1xxxxxx

# 标记为制作中
python3 tools/scripts_manager.py status 草龟 5 in_progress
```

#### 3.4 批量重命名

```bash
# 预览模式（不实际修改）
python3 tools/scripts_manager.py rename 草龟

# 执行模式
python3 tools/scripts_manager.py rename 草龟 --execute
```

**命名规范：**

| 文件类型 | 新命名格式 |
|----------|-----------|
| 主脚本 | `{序号:02d}-{标题}.md` |
| B站发布内容 | `{序号:02d}-B站发布内容.md` |
| 剪映版 | `{序号:02d}-{标题}_剪映版.md` |
| 小红书 | `{序号:02d}-{标题}_小红书.md` |

**预览输出：**

```
📁 重命名预览: 草龟
--------------------------------------------------------------------------------
当前文件名                                    → 新文件名
--------------------------------------------------------------------------------
01-养草龟需要准备什么_小红书发布.md                    → 01-养草龟需要准备什么发布_小红书.md
11-草龟混养-安全组合-B站发布内容.md                   → 11-B站发布内容.md
...
--------------------------------------------------------------------------------
共 7 个文件需要重命名

⚠️  预览模式，未实际执行。添加 --execute 参数执行
```

#### 3.5 导出脚本

```bash
# 导出到默认目录（./export_<物种>）
python3 tools/scripts_manager.py export 草龟

# 导出到指定目录
python3 tools/scripts_manager.py export 草龟 -o ./草龟_备份
```

---

## 文件类型与命名规范

### 标准命名格式

| 文件类型 | 命名模式 | 示例 |
|----------|----------|------|
| 主脚本 | `{序号}-{标题}.md` | `01-养草龟需要准备什么.md` |
| B站发布内容 | `{序号}-B站发布内容.md` | `01-B站发布内容.md` |
| 剪映版 | `{序号}-{标题}_剪映版.md` | `01-养草龟需要准备什么_剪映版.md` |
| 小红书 | `{序号}-{标题}_小红书.md` | `01-养草龟需要准备什么_小红书.md` |
| 封面提示词 | `{序号}-{标题}_封面提示词.md` | `01-养草龟需要准备什么_封面提示词.md` |

### 文件内容说明

| 文件类型 | 内容 | 用途 |
|----------|------|------|
| 主脚本 | 完整视频文案 | 视频制作 |
| B站发布内容 | 标题、标签、简介 | B站发布 |
| 剪映版 | 带时间轴的字幕 | 剪映导入 |
| 小红书 | 图文发布内容 | 小红书发布 |
| 封面提示词 | AI 生图提示词 | 封面制作 |

---

## 索引数据结构

### 顶层结构

```json
{
  "version": "1.0",
  "generated_at": "2026-08-04T21:48:55.200318",
  "stats": {
    "total_files": 1426,
    "species_count": 26,
    "by_type": {
      "script": 964,
      "bilibili_publish": 415,
      "jianying": 37,
      "cover_prompt": 9,
      "xiaohongshu": 1
    }
  },
  "species_stats": {
    "草龟": {
      "total": 76,
      "by_type": {
        "script": 57,
        "bilibili_publish": 17,
        "jianying": 1,
        "xiaohongshu": 1
      }
    }
  },
  "scripts": [...]
}
```

### 单个脚本字段

```json
{
  "species": "草龟",                    // 物种名称
  "episode": 1,                         // 集数
  "title": "养草龟需要准备什么",          // 标题
  "file_type": "script",                // 文件类型
  "relative_path": "草龟/01-养草龟需要准备什么.md",  // 相对路径
  "word_count": 1022,                   // 字数
  "tags": ["新手", "设备"],              // 标签（自动提取）
  "modified_at": "2026-06-01T10:00:00", // 修改时间
  "status": "draft",                    // 状态（手动更新）
  "bilibili_url": null                  // B站链接（手动更新）
}
```

### 冷到你唔信特殊字段

```json
{
  "species": "冷到你唔信",
  "volume": "第五册-鸟类",              // 册子名称
  "species_name": "喜鹊",               // 物种名称
  "episode": 2,                         // 物种序号
  ...
}
```

---

## 工作流场景

### 场景 1：新脚本入库

```bash
# 1. 创建脚本文件
vim docs/video/scripts/草龟/52-新主题.md

# 2. 创建B站发布内容
vim docs/video/scripts/草龟/52-B站发布内容.md

# 3. 更新索引
python3 tools/scripts_indexer.py

# 4. 验证
python3 tools/scripts_search.py -s 草龟 --min 52
```

### 场景 2：视频发布流程

```bash
# 1. 查看待发布脚本
python3 tools/scripts_search.py -s 草龟 -t script

# 2. 制作视频并发布到 B 站

# 3. 更新状态和链接
python3 tools/scripts_manager.py status 草龟 3 published --url https://www.bilibili.com/video/BV1xxxxxx

# 4. 验证更新
python3 tools/scripts_search.py -s 草龟 --verbose
```

### 场景 3：批量整理脚本

```bash
# 1. 查看需要重命名的文件
python3 tools/scripts_manager.py rename 草龟

# 2. 备份（可选）
python3 tools/scripts_manager.py export 草龟 -o ./草龟_备份

# 3. 执行重命名
python3 tools/scripts_manager.py rename 草龟 --execute

# 4. 重新生成索引
python3 tools/scripts_indexer.py
```

### 场景 4：查找特定内容

```bash
# 查找所有繁殖相关内容
python3 tools/scripts_search.py -k 繁殖 -l 50

# 查找草龟 1-10 集的主脚本
python3 tools/scripts_search.py -s 草龟 -t script --min 1 --max 10

# 查找冷到你唔信第七册
python3 tools/scripts_search.py -s 冷到你唔信 -v 第七册

# 查找所有剪映版脚本
python3 tools/scripts_search.py -t jianying
```

### 场景 5：数据统计与分析

```bash
# 查看总体统计
python3 tools/scripts_search.py --stats

# 查看特定物种统计
python3 tools/scripts_search.py --stats -s 草龟

# 生成详细报告
python3 tools/scripts_manager.py report

# 列出所有物种
python3 tools/scripts_manager.py list
```

---

## 常见问题

### Q1: 索引文件不存在或过期？

```bash
# 生成/更新索引
python3 tools/scripts_indexer.py
```

**何时需要更新索引：**
- 添加新脚本后
- 删除脚本后
- 重命名脚本后
- 首次使用工具时

### Q2: 搜索结果为空？

检查项：
1. 索引是否存在：`ls docs/video/scripts/index.json`
2. 物种名称是否正确：`python3 tools/scripts_manager.py list`
3. 关键词是否准确：尝试更短的关键词

### Q3: 冷到你唔信结构复杂？

冷到你唔信采用多层结构：
- 根目录下的册子：`冷到你唔信/第一册-哺乳动物/`
- 全七册下的册子：`冷到你唔信/全七册/第一册-哺乳动物/`
- 归档备份：`冷到你唔信/全七册/_archive/`（忽略）

使用 `-v` 参数指定册子：
```bash
python3 tools/scripts_search.py -s 冷到你唔信 -v 第五册
```

### Q4: 重命名后需要做什么？

重命名后必须重新生成索引：
```bash
python3 tools/scripts_indexer.py
```

### Q5: 如何批量更新状态？

目前 `status` 命令只支持单个脚本。如需批量更新，建议：
1. 直接编辑 `index.json`
2. 或编写脚本调用 `ScriptsManager.update_status()`

### Q6: 索引文件太大怎么办？

`index.json` 包含所有脚本的元数据，当前约 300KB。如果后续脚本量继续增长，可以考虑：
1. 按物种拆分索引
2. 使用 SQLite 数据库

---

## 最佳实践

### 1. 定期更新索引

建议在每次添加/修改脚本后立即更新索引：
```bash
python3 tools/scripts_indexer.py
```

### 2. 保持命名规范

遵循标准命名格式，便于工具识别：
- 主脚本：`{序号:02d}-{标题}.md`
- B站发布内容：`{序号:02d}-B站发布内容.md`
- 剪映版：`{序号:02d}-{标题}_剪映版.md`

### 3. 及时更新发布状态

视频发布后立即更新状态和链接：
```bash
python3 tools/scripts_manager.py status <物种> <集数> published --url <链接>
```

### 4. 定期备份

导出重要物种的脚本：
```bash
python3 tools/scripts_manager.py export 草龟 -o ./备份/草龟_$(date +%Y%m%d)
```

### 5. 使用 Git 追踪变更

索引文件 `index.json` 建议加入 Git 追踪：
```bash
git add docs/video/scripts/index.json
git commit -m "更新脚本索引"
```

---

## 命令速查表

| 操作 | 命令 |
|------|------|
| 生成索引 | `python3 tools/scripts_indexer.py` |
| 搜索物种 | `python3 tools/scripts_search.py -s <物种>` |
| 搜索关键词 | `python3 tools/scripts_search.py -k <关键词>` |
| 搜索文件类型 | `python3 tools/scripts_search.py -t <类型>` |
| 查看统计 | `python3 tools/scripts_search.py --stats` |
| 更新状态 | `python3 tools/scripts_manager.py status <物种> <集数> <状态>` |
| 预览重命名 | `python3 tools/scripts_manager.py rename <物种>` |
| 执行重命名 | `python3 tools/scripts_manager.py rename <物种> --execute` |
| 导出脚本 | `python3 tools/scripts_manager.py export <物种>` |
| 查看报告 | `python3 tools/scripts_manager.py report` |
| 列出物种 | `python3 tools/scripts_manager.py list` |

---

*文档版本: 2.0*
*创建时间: 2026-08-04*
*维护者: WildHerd Team*
