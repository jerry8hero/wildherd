# WildHerd 内容生产工具链

`tools/` 目录下是从 `scripts/` 与原有 `tools/` 合并后的全部内容生产、审核、发布工具。Flutter 应用本身（`lib/`）不依赖此目录。

## 目录结构

```
tools/
├── collector.py             # 知识库采集 V2（多源爬取）
├── knowledge_collector.py   # 知识库采集 V1（旧版，可作历史参考）
├── minimax_client.py        # MiniMax API 客户端（脚本生成、标题、简介）
├── comfyui_api.py           # ComfyUI 客户端（线稿图生成）
├── base_api_client.py       # HTTP 客户端抽象基类
├── errors.py                # 异常层次
├── pdf_ocr.py               # PDF OCR
├── setup_comfyui.sh         # ComfyUI 安装脚本
├── setup_minimax.sh         # MiniMax CLI 安装脚本
├── video-script-generator.js  # Node.js：根据 species-list.txt 批量生成脚本
├── configs/                 # 配置
│   ├── auto_replies.yml
│   ├── publishing_schedule.yml
│   └── species-list.txt
├── publishing/              # B 站发布相关
│   ├── bilibili_publisher.py
│   ├── bgm_finder.py
│   ├── check_pending.py
│   ├── content_checker.py
│   ├── md2xiaohongshu.py
│   └── update_records.py
├── review/                  # 视频文案 Review（多实现并存）
│   ├── auto_review.py       # ★ 主入口：3 轮 LLM Review
│   ├── review_core.py       # 共享：MiniMaxClient + ReviewConfig
│   ├── state_manager.py     # 断点续传
│   ├── review_logger.py     # JSON 报告
│   ├── review_bilibili.py   # B 站发布内容 review
│   ├── review_putonghua.py  # 普通话风格 review
│   ├── review_volume4.py    # 冷到你唔信 / 第四册专用
│   ├── minimax_reviewer.py  # tools/ 旧版 MiniMax reviewer
│   ├── deepseek_reviewer.py # DeepSeek reviewer
│   ├── review_manager.py
│   ├── review_workflow.py
│   └── config.json          # auto_review.py 默认配置
├── video/                   # 视频生产
│   ├── video_workflow.py    # TTS + 字幕 + 合成 + 发布 主流程
│   ├── ai_video_workflow.py
│   ├── batch_workflow.py    # 批量处理
│   ├── batch_state.py
│   ├── batch_config.py
│   ├── storyboard_generator.py
│   ├── tts_generator.py
│   ├── subtitle_generator.py
│   ├── video_assembler.py
│   ├── lineart_post_processor.py
│   ├── style_processor.py
│   └── turtle_image_collector.py
├── prompts/                 # LLM 提示词模板
├── state/                   # 运行时输出（已 gitignore）
└── archive/                 # 归档脚本（待清理）
    ├── test_apis.py
    └── test_weather.py
```

## 环境变量

复制 `tools/.env.example` 为 `tools/.env` 并填入：

```bash
MINIMAX_API_KEY=sk-cp-...    # 必需
```

不提交 `.env` 文件（已 gitignore）。`review_bilibili.py` 和 `review_putonghua.py` 会优先读 `MINIMAX_API_KEY`。

## 常用入口

### 视频文案 Review

```bash
# 主入口：3 轮分维度 Review（含断点续传）
python tools/review/auto_review.py 5 20

# 单文件 Review
python tools/review/review_bilibili.py path/to/发布内容.md
python tools/review/review_putonghua.py path/to/视频文案.md
```

### 视频生产

```bash
python tools/video/video_workflow.py --config tools/configs/species-list.txt
```

### B 站发布

```bash
python tools/publishing/bilibili_publisher.py upload
python tools/publishing/check_pending.py
```

### 知识采集

```bash
python tools/collector.py --category turtle
```

## 依赖安装

```bash
pip install -r tools/requirements.txt
```

## 已知的非合并冗余

`tools/review/` 下有两套并行 Review 实现：
- `auto_review.py` / `review_core.py` / `review_logger.py` / `state_manager.py`（主分支）
- `review_bilibili.py` / `review_putonghua.py` / `review_volume4.py`（独立脚本，硬编码 review 流程）
- `minimax_reviewer.py` / `deepseek_reviewer.py` / `review_manager.py` / `review_workflow.py`（tools/ 旧链）

合并到统一 API 的重构列为后续 PR，不在本轮范围。
