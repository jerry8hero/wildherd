# 素材管理规范

## 目录结构

```
wildherd/
├── docs/                   # 视频脚本文档
├── materials/              # 素材类
│   ├── videos/            # 视频素材
│   │   └── {系列名}/
│   │       └── {期数}-{内容标题}/
│   │           ├── raw/              # 原始素材
│   │           └── edited/           # 剪辑后版本
│   ├── thumbnails/        # 封面素材
│   │   └── {系列名}/
│   │       └── {期数}-{内容标题}/
│   ├── assets/            # 通用素材
│   │   ├── bgm/           # 背景音乐
│   │   ├── sfx/           # 音效
│   │   └── templates/     # 剪辑模板
│   └── reference/         # 参考素材
├── output/                # 成片输出
│   └── {系列名}/
│       └── {期数}-{内容标题}-final.mp4
└── backups/               # 备份目录（软链接到云盘）
```

## 命名规范

### 格式
```
{序号}-{系列缩写}-{内容标题}-{类型}-{版本}
```

### 系列缩写表
| 系列 | 缩写 |
|------|------|
| 鳄龟 | e-guihu |
| 草龟 | c-guihu |
| 红面蛋龟 | rmt-guihu |
| 锯缘摄龟 | juyu |
| (其他) | 自定义 |

### 示例
```
01-e-guihu-xinren-script-v1.md      # 脚本v1
01-e-guihu-xinren-script-final.md   # 脚本定稿
01-e-guihu-xinren-thumb-psd.psd     # 封面PSD
01-e-guihu-xinren-thumb-png.png     # 封面成品
01-e-guihu-xinren-raw-001.mp4       # 原始素材
01-e-guihu-xinren-final.mp4         # 成片
```

## Git LFS

大文件（视频、图片、音频）由 Git LFS 管理：

```bash
# 安装 Git LFS（仅需一次）
git lfs install

# 查看 LFS 追踪状态
git lfs status

# 推送时上传 LFS 文件
git push
```

## 新增系列流程

1. 在 `docs/video-scripts/` 下创建系列文件夹
2. 在 `materials/` 对应位置创建系列文件夹
3. 在 `output/` 下创建系列文件夹
4. 在本文档「系列缩写表」中添加新系列

## 素材归档

- 每周整理一次素材
- 已发布的视频原始素材移到 `raw/archive/`
- 定期清理无用素材
- 备份同步到云盘
