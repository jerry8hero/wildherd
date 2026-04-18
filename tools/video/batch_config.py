#!/usr/bin/env python3
"""
批量视频制作工作流 - 配置文件

定义龟种、路径模板、默认参数等配置
"""

import os
from pathlib import Path
from typing import Dict, Any

# 项目根目录
PROJECT_ROOT = Path(__file__).parent.parent.parent
DOCS_VIDEO = PROJECT_ROOT / "docs" / "video"
OUTPUT_DIR = PROJECT_ROOT / "output"
BATCH_STATUS_DIR = OUTPUT_DIR / "batch_status"
VIDEO_OUTPUT_DIR = OUTPUT_DIR / "video"

# 确保目录存在
BATCH_STATUS_DIR.mkdir(parents=True, exist_ok=True)

# 龟种配置
TURTLE_TYPES: Dict[str, Dict[str, Any]] = {
    "草龟": {
        "script_dir": "草龟",
        "output_dir": "草龟",
        "tags": ["爬宠", "养龟", "草龟", "新手入门"],
        "default_voice": "xiaoxiao",
        "description": "草龟 - 国龟经典，新手首选"
    },
    "巴西龟": {
        "script_dir": "巴西龟",
        "output_dir": "巴西龟",
        "tags": ["爬宠", "养龟", "巴西龟", "入门级"],
        "default_voice": "xiaoxiao",
        "description": "巴西龟 - 入门经典，活泼好养"
    },
    "蛋龟": {
        "script_dir": "蛋龟",
        "output_dir": "蛋龟",
        "tags": ["爬宠", "养龟", "蛋龟", "深水龟"],
        "default_voice": "xiaoxiao",
        "description": "蛋龟 - 互动性强，深水饲养"
    },
    "侧颈龟": {
        "script_dir": "侧颈龟",
        "output_dir": "侧颈龟",
        "tags": ["爬宠", "养龟", "侧颈龟", "热带龟"],
        "default_voice": "xiaoxiao",
        "description": "侧颈龟 - 呆萌可爱，热带品种"
    },
    "中华花龟": {
        "script_dir": "中华花龟",
        "output_dir": "中华花龟",
        "tags": ["爬宠", "养龟", "中华花龟", "国龟"],
        "default_voice": "xiaoxiao",
        "description": "中华花龟 - 国龟之美，被低估的品种"
    },
    "木纹龟": {
        "script_dir": "木纹龟",
        "output_dir": "木纹龟",
        "tags": ["爬宠", "养龟", "木纹龟", "南美龟"],
        "default_voice": "xiaoxiao",
        "description": "木纹龟 - 南美风情，体型大"
    },
    "欧泽龟": {
        "script_dir": "欧泽龟",
        "output_dir": "欧泽龟",
        "tags": ["爬宠", "养龟", "欧泽龟", "欧洲泽龟"],
        "default_voice": "xiaoxiao",
        "description": "欧泽龟 - 欧洲进口，花纹美丽"
    },
    "鳄龟": {
        "script_dir": "鳄龟",
        "output_dir": "鳄龟",
        "tags": ["爬宠", "养龟", "鳄龟", "凶猛"],
        "default_voice": "yunyang",  # 鳄龟用男声更有特色
        "description": "鳄龟 - 霸气凶猛，战斗力强"
    }
}

# 默认配置
DEFAULT_CONFIG = {
    "review_rounds": 3,  # DeepSeek review 迭代轮数
    "voice": "xiaoxiao",  # TTS 声音: xiaoxiao/xiaoyi/yuni/yunyang/xiaoxuan/xiaobai
    "comfyui_host": "127.0.0.1",
    "comfyui_port": 8188,
    "parallel_tasks": 1,  # 并行任务数，暂只支持串行
    "skip_review": False,
    "skip_lineart": True,  # 默认跳过 AI 绘图（使用静态图片代替）
    "skip_bgm": False,
    "skip_publish": True,  # 默认跳过发布
    "ffmpeg_preset": "fast",
    "video_quality": "high",  # low/medium/high
}

# 素材图片目录配置
# 优先级：环境变量 > 项目默认目录
# 使用环境变量 WILDHIRD_TURTLE_IMAGES_DIR 指定外部素材目录
# 这样可以将素材存储在 repo 外部，通过符号链接或路径引用使用
ASSETS_DIR = PROJECT_ROOT / "assets"
TURTLE_IMAGES_DIR = Path(os.environ.get(
    "WILDHIRD_TURTLE_IMAGES_DIR",
    str(ASSETS_DIR / "turtle-images")
))
DEFAULT_FRAME_DURATION = 3  # 每张图片默认显示秒数

# 视频质量设置
VIDEO_QUALITY_PRESETS = {
    "low": {
        "crf": 28,
        "preset": "veryfast",
        "description": "低质量，文件小"
    },
    "medium": {
        "crf": 23,
        "preset": "fast",
        "description": "中等质量，平衡"
    },
    "high": {
        "crf": 18,
        "preset": "medium",
        "description": "高质量，文件大"
    }
}

# TTS 声音选项
TTS_VOICES = {
    "xiaoxiao": "晓晓 (年轻女声，推荐)",
    "xiaoyi": "小艺 (年轻女声)",
    "yuni": "云希 (年轻女声)",
    "yunyang": "云扬 (男声)",
    "xiaoxuan": "小璇 (年轻女声)",
    "xiaobai": "小白 (年轻女声)"
}

# 处理步骤
PROCESS_STEPS = [
    "review",
    "storyboard",
    "frames",
    "tts",
    "subtitle",
    "bgm",
    "assemble",
    "cover",
    "publish"
]

STEP_DESCRIPTIONS = {
    "review": "文案 Review (DeepSeek)",
    "storyboard": "分镜生成",
    "frames": "素材图片 (静态轮播)",
    "tts": "TTS 配音",
    "subtitle": "字幕生成",
    "bgm": "BGM 匹配",
    "assemble": "视频组装",
    "cover": "封面生成",
    "publish": "B站发布"
}

# 状态定义
TASK_STATUS = {
    "PENDING": "待处理",
    "PROCESSING": "处理中",
    "COMPLETED": "已完成",
    "FAILED": "失败",
    "SKIPPED": "已跳过"
}

STEP_STATUS = {
    "PENDING": "待执行",
    "PROCESSING": "执行中",
    "COMPLETED": "已完成",
    "FAILED": "失败",
    "SKIPPED": "已跳过"
}


def get_turtle_config(turtle_type: str) -> Dict[str, Any]:
    """获取龟种配置"""
    return TURTLE_TYPES.get(turtle_type, TURTLE_TYPES["草龟"])


def get_script_dir(turtle_type: str) -> Path:
    """获取龟种文案目录"""
    config = get_turtle_config(turtle_type)
    return DOCS_VIDEO / "scripts" / config["script_dir"]


def get_output_dir(turtle_type: str) -> Path:
    """获取龟种输出目录"""
    config = get_turtle_config(turtle_type)
    return VIDEO_OUTPUT_DIR / config["output_dir"]


def ensure_dirs():
    """确保必要目录存在"""
    for d in [OUTPUT_DIR, BATCH_STATUS_DIR, VIDEO_OUTPUT_DIR]:
        d.mkdir(parents=True, exist_ok=True)
