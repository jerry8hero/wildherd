# 素材管理使用指南

## 目录结构总览

```
wildherd/
├── docs/                              # 视频脚本文档
│   └── video-scripts/                 # 按系列分类的脚本
│       └── 鳄龟/                     # 示例：鳄龟系列
│           ├── 01-养鳄龟选大还是小？/
│           └── 02-装备指南/
│
├── materials/                         # 素材类（存放原始素材）
│   ├── videos/                       # 视频素材
│   │   └── 鳄龟/
│   │       └── 01-新手入门/
│   │           ├── raw/              # 原始录屏/片段
│   │           └── edited/           # 剪辑后的版本
│   ├── thumbnails/                   # 封面素材
│   │   └── 鳄龟/
│   │       └── 01-新手入门/
│   │           ├── 封面文案.txt
│   │           └── 封面图.psd/png
│   ├── assets/                       # 通用素材
│   │   ├── bgm/                      # 背景音乐
│   │   ├── sfx/                      # 音效
│   │   └── templates/                # 剪辑模板
│   └── reference/                    # 参考素材
│
├── output/                            # 成片输出
│   └── 鳄龟/
│       └── 01-新手入门/
│           └── 01-养鳄龟选大还是小？-final.mp4
│
└── backups/                           # 备份（软链接到云盘）
```

---

## 命名规范

### 文件命名格式
```
{序号}-{系列缩写}-{内容标题}-{类型}-{版本}
```

### 系列缩写表

| 系列 | 缩写 | 示例前缀 |
|------|------|----------|
| 鳄龟 | e-guihu | 01-e-guihu |
| 草龟 | c-guihu | 01-c-guihu |
| 红面蛋龟 | rmt-guihu | 01-rmt-guihu |
| 锯缘摄龟 | juyu | 01-juyu |

### 命名示例

**脚本文件：**
```
01-e-guihu-xinren-script-v1.md      # 脚本初稿
01-e-guihu-xinren-script-v2.md      # 脚本修改版
01-e-guihu-xinren-script-final.md   # 脚本定稿
```

**封面素材：**
```
01-e-guihu-xinren-thumb-psd.psd     # 封面PSD源文件
01-e-guihu-xinren-thumb-png.png     # 封面成品图
```

**视频素材：**
```
01-e-guihu-xinren-raw-001.mp4       # 原始素材片段1
01-e-guihu-xinren-raw-002.mp4       # 原始素材片段2
01-e-guihu-xinren-edited-v1.mp4     # 剪辑版本1
01-e-guihu-xinren-final.mp4         # 最终成片
```

---

## 日常使用流程

### 1. 开始新视频项目

```
# 1. 在 docs/video-scripts/ 下创建系列文件夹（如尚未存在）
mkdir -p docs/video-scripts/鳄龟/02-装备指南

# 2. 在 materials/videos/ 下创建对应文件夹
mkdir -p materials/videos/鳄龟/02-装备指南/{raw,edited}

# 3. 在 materials/thumbnails/ 下创建对应文件夹
mkdir -p materials/thumbnails/鳄龟/02-装备指南

# 4. 在 output/ 下创建对应文件夹
mkdir -p output/鳄龟/02-装备指南
```

### 2. 素材命名示例

```
# 脚本命名
docs/video-scripts/鳄龟/02-装备指南/02-装备指南-script-v1.md

# 封面命名
materials/thumbnails/鳄龟/02-装备指南/02-e-guihu-zhuangbei-thumb-psd.psd

# 视频素材命名
materials/videos/鳄龟/02-装备指南/raw/02-e-guihu-zhuangbei-raw-001.mp4
materials/videos/鳄龟/02-装备指南/edited/02-e-guihu-zhuangbei-edited-v1.mp4

# 成片命名
output/鳄龟/02-装备指南/02-e-guihu-zhuangbei-final.mp4
```

### 3. Git LFS 使用

```bash
# 首次使用需安装 Git LFS（仅需一次）
git lfs install

# 追踪大文件（.gitattributes 已配置，自动生效）
# 如需手动添加：
git lfs track "*.mp4"
git lfs track "*.psd"

# 查看 LFS 文件状态
git lfs status

# 提交时 LFS 文件会自动上传
git add .
git commit -m "添加新视频素材"
git push
```

---

## 素材分类说明

### materials/videos/ - 视频素材
| 子目录 | 用途 |
|--------|------|
| raw/ | 原始录屏、拍摄片段、未经剪辑的素材 |
| edited/ | 经过初步剪辑的版本，用于拼接成片 |

### materials/thumbnails/ - 封面素材
| 文件类型 | 用途 |
|----------|------|
| .psd | 封面源文件，可继续修改 |
| .png/.jpg | 封面成品图，直接用于发布 |
| .txt | 封面文案草稿 |

### materials/assets/ - 通用素材
| 子目录 | 用途 |
|--------|------|
| bgm/ | 背景音乐，按风格/情绪分类 |
| sfx/ | 音效，如转场声、提示音 |
| templates/ | 剪辑模板、预设 |

### materials/reference/ - 参考素材
| 子目录 | 用途 |
|--------|------|
| 参考视频/ | 学习借鉴的其他创作者视频 |
| 资料文档/ | 收集的龟类品种资料、图片 |

### output/ - 成片输出
存放最终剪辑完成的成片，命名格式：`{序号}-{系列缩写}-{内容标题}-final.{格式}`

---

## 备份策略

### 三二一原则
- **3份副本**：原始文件 + 本地备份 + 云盘备份
- **2种介质**：本地硬盘 + 云盘
- **1份异地**：云盘作为异地备份

### 备份操作

```bash
# 每月至少进行一次备份检查
# 1. 检查 output/ 目录下的成片是否完整
# 2. 检查 materials/ 目录是否有新增素材需要归档
# 3. 确保云盘同步正常
```

### 云盘同步建议

将 `backups/` 目录软链接到云盘同步目录：

```bash
# 示例：将百度网盘同步目录链接到 backups
ln -s /path/to/baidunetdisk/wildherd-backup backups
```

---

## 常见问题

**Q: 大文件推送到 Git 时失败？**
A: 确保已安装 Git LFS 并正确追踪文件类型。检查 `.gitattributes` 配置。

**Q: 素材放错目录了怎么办？**
A: 使用 `git mv` 移动文件以保留提交历史：`git mv old/path new/path`

**Q: 如何清理不需要的素材？**
A: 在删除本地文件前，确保已备份到云盘。然后使用 `git rm` 移除追踪记录。

---

## 系列新增流程

当需要新增一个系列（如草龟系列）时：

1. 在 `docs/video-scripts/` 下创建 `草龟/` 文件夹
2. 在 `materials/videos/` 下创建 `草龟/` 文件夹
3. 在 `materials/thumbnails/` 下创建 `草龟/` 文件夹
4. 在 `materials/reference/` 下创建 `草龟/` 文件夹
5. 在 `output/` 下创建 `草龟/` 文件夹
6. 在本表格添加新系列缩写：`草龟 → c-guihu`
