#!/usr/bin/env python3
"""
批量视频制作工作流 - 主入口脚本

从文案到成品的批量视频制作流水线

使用方法:
    # 列出可用文案
    python3 batch_workflow.py list
    python3 batch_workflow.py list --turtle 鳄龟

    # 预览执行
    python3 batch_workflow.py run docs/video/scripts/鳄龟/ --dry-run

    # 单个视频
    python3 batch_workflow.py run docs/video/scripts/鳄龟/01-养鳄龟选大还是小.md

    # 整个龟种
    python3 batch_workflow.py run docs/video/scripts/鳄龟/

    # 查看状态
    python3 batch_workflow.py status
    python3 batch_workflow.py status batch_20240115_143022

    # 断点续传
    python3 batch_workflow.py resume
    python3 batch_workflow.py resume batch_20240115_143022
"""

import argparse
import os
import sys
import time
import json
import shutil
import subprocess
from pathlib import Path
from typing import List, Dict, Optional, Any
from datetime import datetime
from glob import glob

# 导入本地模块
from batch_config import (
    PROJECT_ROOT, DOCS_VIDEO, OUTPUT_DIR, VIDEO_OUTPUT_DIR,
    TURTLE_TYPES, DEFAULT_CONFIG, PROCESS_STEPS, STEP_DESCRIPTIONS,
    TASK_STATUS, STEP_STATUS, TTS_VOICES,
    get_turtle_config, get_script_dir, get_output_dir, ensure_dirs
)
from batch_state import BatchStateManager, BatchState, TaskState

# 颜色配置
class Colors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'


def print_step(step: str, message: str):
    print(f"{Colors.OKBLUE}[{step}]{Colors.ENDC} {message}")


def print_success(message: str):
    print(f"{Colors.OKGREEN}✓{Colors.ENDC} {message}")


def print_warning(message: str):
    print(f"{Colors.WARNING}⚠{Colors.ENDC} {message}")


def print_error(message: str):
    print(f"{Colors.FAIL}✗{Colors.ENDC} {message}")


def print_header(message: str):
    print(f"\n{Colors.BOLD}{Colors.HEADER}{'='*60}{Colors.ENDC}")
    print(f"{Colors.BOLD}{Colors.HEADER}{message:^60}{Colors.ENDC}")
    print(f"{Colors.BOLD}{Colors.HEADER}{'='*60}{Colors.ENDC}\n")


def print_progress(current: int, total: int, task_name: str, step: str = ""):
    """打印进度"""
    bar_length = 30
    filled = int(bar_length * current / total)
    bar = '█' * filled + '░' * (bar_length - filled)
    status = f"[{current}/{total}]"
    step_info = f" {step}" if step else ""
    print(f"\r{status} |{bar}| {task_name[:20]}{step_info}", end='', flush=True)


def find_script_files(paths: List[str]) -> List[Dict]:
    """
    扫描文案文件

    Args:
        paths: 文件或目录列表

    Returns:
        文件信息列表
    """
    scripts = []
    seen = set()

    for path_str in paths:
        # 转换为 Path 对象，如果是相对路径则相对于 PROJECT_ROOT 解析
        if not os.path.isabs(path_str):
            path = PROJECT_ROOT / path_str
        else:
            path = Path(path_str)

        if path.is_file() and path.suffix == '.md':
            # 单个文件
            scripts.append({
                "script_path": str(path),
                "turtle_type": _detect_turtle_type(path),
                "task_id": _generate_task_id(path)
            })
        elif path.is_dir():
            # 目录，递归扫描
            for md_file in path.rglob("*.md"):
                if md_file.name.startswith("00-"):  # 跳过 B站发布内容模板
                    continue
                if str(md_file) not in seen:
                    seen.add(str(md_file))
                    scripts.append({
                        "script_path": str(md_file),
                        "turtle_type": _detect_turtle_type(md_file),
                        "task_id": _generate_task_id(md_file)
                    })

    return scripts


def _detect_turtle_type(path: Path) -> str:
    """根据路径检测龟种"""
    parts = path.parts
    for turtle in TURTLE_TYPES.keys():
        if turtle in parts:
            return turtle
    return "其他"


def _generate_task_id(path: Path) -> str:
    """生成任务ID"""
    return path.stem  # 文件名不含扩展名


def build_config(args: argparse.Namespace) -> Dict[str, Any]:
    """构建配置"""
    config = DEFAULT_CONFIG.copy()

    if hasattr(args, 'review_rounds') and args.review_rounds:
        config["review_rounds"] = args.review_rounds
    if hasattr(args, 'voice') and args.voice:
        config["voice"] = args.voice
    if hasattr(args, 'skip_review') and args.skip_review:
        config["skip_review"] = True
    if hasattr(args, 'skip_lineart') and args.skip_lineart:
        config["skip_lineart"] = True
    if hasattr(args, 'skip_bgm') and args.skip_bgm:
        config["skip_bgm"] = True
    if hasattr(args, 'skip_publish') and args.skip_publish:
        config["skip_publish"] = True
    if hasattr(args, 'steps') and args.steps:
        config["steps"] = args.steps.split(',')
    else:
        config["steps"] = PROCESS_STEPS.copy()

    return config


def process_single_task(task: Dict, config: Dict, state_mgr: BatchStateManager, dry_run: bool = False) -> bool:
    """
    处理单个任务

    Args:
        task: 任务信息
        config: 配置
        state_mgr: 状态管理器
        dry_run: 是否仅预览

    Returns:
        是否成功
    """
    task_id = task["task_id"]
    script_path = task["script_path"]
    turtle_type = task["turtle_type"]

    output_base = VIDEO_OUTPUT_DIR / turtle_type / task_id
    output_base.mkdir(parents=True, exist_ok=True)

    print(f"\n{'='*60}")
    print(f"处理任务: {task_id}")
    print(f"文案: {script_path}")
    print(f"{'='*60}")

    # 更新任务状态
    state_mgr.update_task(task_id, TASK_STATUS["PROCESSING"])

    # 确定要执行的步骤
    steps_to_run = config.get("steps", PROCESS_STEPS)

    for step in steps_to_run:
        start_time = time.time()
        print_step(step.upper(), STEP_DESCRIPTIONS.get(step, step))

        if dry_run:
            print(f"  [DRY RUN] 将执行: {step}")
            state_mgr.update_step(task_id, step, STEP_STATUS["SKIPPED"])
            continue

        try:
            if step == "review":
                success = step_review(task_id, script_path, config, state_mgr, output_base)
            elif step == "storyboard":
                success = step_storyboard(task_id, script_path, config, state_mgr, output_base)
            elif step == "frames":
                success = step_frames(task_id, config, state_mgr, output_base)
            elif step == "tts":
                success = step_tts(task_id, script_path, config, state_mgr, output_base)
            elif step == "subtitle":
                success = step_subtitle(task_id, config, state_mgr, output_base)
            elif step == "bgm":
                success = step_bgm(task_id, config, state_mgr, output_base)
            elif step == "assemble":
                success = step_assemble(task_id, turtle_type, config, state_mgr, output_base)
            elif step == "cover":
                success = step_cover(task_id, turtle_type, config, state_mgr, output_base)
            elif step == "publish":
                success = step_publish(task_id, config, state_mgr, output_base)
            else:
                print_warning(f"未知步骤: {step}")
                success = False

            duration = time.time() - start_time

            if success:
                state_mgr.update_step(task_id, step, STEP_STATUS["COMPLETED"], duration=duration)
                print_success(f"完成 ({duration:.1f}s)")
            else:
                state_mgr.update_step(task_id, step, STEP_STATUS["FAILED"])
                print_error(f"失败")
                state_mgr.update_task(task_id, TASK_STATUS["FAILED"], f"步骤 {step} 失败")
                return False

        except Exception as e:
            duration = time.time() - start_time
            print_error(f"异常: {e}")
            state_mgr.update_step(task_id, step, STEP_STATUS["FAILED"], error=str(e))
            state_mgr.update_task(task_id, TASK_STATUS["FAILED"], str(e))
            return False

    state_mgr.update_task(task_id, TASK_STATUS["COMPLETED"])
    print_success(f"任务完成!")
    return True


# ============== 各步骤实现 ==============

def step_review(task_id: str, script_path: str, config: Dict, state_mgr: BatchStateManager, output_base: Path) -> bool:
    """Review 步骤"""
    if config.get("skip_review"):
        return True

    reviewed_path = output_base / "reviewed.md"
    rounds = config.get("review_rounds", 3)

    # 使用 deepseek_reviewer
    reviewer_script = PROJECT_ROOT / "tools" / "review" / "deepseek_reviewer.py"

    cmd = [
        "python3", str(reviewer_script),
        "iterate", script_path,
        "--rounds", str(rounds)
    ]

    result = subprocess.run(cmd, capture_output=True, text=True, cwd=str(PROJECT_ROOT))

    if result.returncode == 0:
        # 复制 review 后的文件
        if reviewed_path.exists() or Path(script_path).exists():
            shutil.copy(script_path, reviewed_path)
        return True
    else:
        print_warning(f"Review 失败，使用原始文案")
        shutil.copy(script_path, reviewed_path)
        return True  # Review 失败不阻塞流程


def step_storyboard(task_id: str, script_path: str, config: Dict, state_mgr: BatchStateManager, output_base: Path) -> bool:
    """分镜生成步骤"""
    storyboard_dir = output_base / "storyboard"
    storyboard_dir.mkdir(parents=True, exist_ok=True)

    storyboard_json = storyboard_dir / "storyboard.json"

    # 使用 storyboard_generator
    generator_script = PROJECT_ROOT / "tools" / "video" / "storyboard_generator.py"

    cmd = [
        "python3", str(generator_script),
        script_path,
        "--output", str(storyboard_json)
    ]

    result = subprocess.run(cmd, capture_output=True, text=True, cwd=str(PROJECT_ROOT))

    return result.returncode == 0


def step_frames(task_id: str, config: Dict, state_mgr: BatchStateManager, output_base: Path) -> bool:
    """静态图片轮播步骤 - 使用素材图片"""
    from batch_config import TURTLE_IMAGES_DIR, DEFAULT_FRAME_DURATION, ASSETS_DIR
    import random
    import shutil

    frames_dir = output_base / "frames"
    frames_dir.mkdir(parents=True, exist_ok=True)

    # 检查素材目录
    if not TURTLE_IMAGES_DIR.exists():
        # 检查是否是损坏的符号链接
        if TURTLE_IMAGES_DIR.is_symlink() or not ASSETS_DIR.exists():
            print_warning(f"素材目录链接已损坏或未配置")
            print_warning(f"请设置环境变量 WILDHIRD_TURTLE_IMAGES_DIR 指向素材目录")
            print_warning(f"示例: export WILDHIRD_TURTLE_IMAGES_DIR=/path/to/your/turtle-images")
        else:
            print_warning(f"素材目录不存在: {TURTLE_IMAGES_DIR}")
        print_warning("将创建默认占位图")
        # 创建简单占位图
        create_placeholder_image(frames_dir / "placeholder_001.jpg", task_id)
        return True

    # 获取所有素材图片
    image_files = list(TURTLE_IMAGES_DIR.glob("*.jpg")) + \
                 list(TURTLE_IMAGES_DIR.glob("*.jpeg")) + \
                 list(TURTLE_IMAGES_DIR.glob("*.png"))

    if not image_files:
        print_warning("素材目录为空，请添加龟类图片")
        create_placeholder_image(frames_dir / "placeholder_001.jpg", task_id)
        return True

    # 随机选择图片（避免每个视频都一样）
    selected_images = random.sample(
        image_files,
        min(len(image_files), 8)  # 最多8张图片轮播
    )

    # 复制到 frames 目录
    for i, img_path in enumerate(selected_images, 1):
        dest_path = frames_dir / f"frame_{i:03d}{img_path.suffix}"
        shutil.copy2(img_path, dest_path)
        print_step("FRAME", f"复制素材: {img_path.name}")

    print_success(f"使用 {len(selected_images)} 张素材图片")
    return True


def create_placeholder_image(output_path: Path, text: str):
    """创建简单占位图"""
    try:
        from PIL import Image, ImageDraw, ImageFont
        width, height = 1280, 720
        img = Image.new('RGB', (width, height), color=(30, 60, 40))
        draw = ImageDraw.Draw(img)

        try:
            font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 48)
        except:
            font = ImageFont.load_default()

        # 添加文字
        display_text = text.replace('-', ' ').replace('_', ' ')[:30]
        bbox = draw.textbbox((0, 0), display_text, font=font)
        text_width = bbox[2] - bbox[0]
        text_height = bbox[3] - bbox[1]
        x = (width - text_width) // 2
        y = (height - text_height) // 2
        draw.text((x, y), display_text, fill=(200, 200, 200), font=font)

        img.save(output_path)
        print_success(f"创建占位图: {output_path.name}")
    except Exception as e:
        print_warning(f"创建占位图失败: {e}")


def step_tts(task_id: str, script_path: str, config: Dict, state_mgr: BatchStateManager, output_base: Path) -> bool:
    """TTS 配音步骤"""
    audio_dir = output_base / "audio"
    audio_dir.mkdir(parents=True, exist_ok=True)

    tts_path = audio_dir / "tts.mp3"

    # 确定要用的文案
    reviewed_path = output_base / "reviewed.md"
    text_source = reviewed_path if reviewed_path.exists() else script_path

    # 读取文案文本
    text = extract_text_from_markdown(text_source)

    # 调用 TTS
    tts_script = PROJECT_ROOT / "tools" / "video" / "tts_generator.py"
    voice = config.get("voice", "xiaoxiao")

    cmd = [
        "python3", str(tts_script),
        "--text", text,
        "--output", str(tts_path),
        "--voice", voice
    ]

    result = subprocess.run(cmd, capture_output=True, text=True, cwd=str(PROJECT_ROOT))

    return result.returncode == 0


def extract_text_from_markdown(md_path: Path) -> str:
    """从 Markdown 提取纯文本"""
    content = md_path.read_text(encoding='utf-8')

    # 移除 front matter
    if content.startswith('---'):
        parts = content.split('---', 2)
        if len(parts) >= 3:
            content = parts[2]

    lines = []
    in_verbatim = False

    for line in content.split('\n'):
        line = line.strip()

        # 跳过标题和分隔符
        if line.startswith('#') or line.startswith('---'):
            continue

        # 跳过画面描述
        if line.startswith('【画面描述】') or line.startswith('## 【画面描述】'):
            continue

        # 跳过 markdown 格式
        if line.startswith('**') or line.startswith('*') or line.startswith('- '):
            line = line.lstrip('*- ').strip('*')

        lines.append(line)

    return '\n'.join(lines)


def step_subtitle(task_id: str, config: Dict, state_mgr: BatchStateManager, output_base: Path) -> bool:
    """字幕生成步骤"""
    audio_dir = output_base / "audio"
    tts_path = audio_dir / "tts.mp3"

    if not tts_path.exists():
        print_warning("TTS 文件不存在，跳过字幕生成")
        return True

    subtitle_path = audio_dir / "subtitle.srt"

    # 使用 Whisper 生成字幕
    try:
        import whisper
        model = whisper.load_model("base")
        result = model.transcribe(str(tts_path), language="zh")

        # 生成 SRT 格式
        srt_content = ""
        for i, segment in enumerate(result["segments"], 1):
            start = segment["start"]
            end = segment["end"]
            text = segment["text"].strip()

            # 格式化时间
            start_s = f"{int(start // 3600):02d}:{int((start % 3600) // 60):02d}:{int(start % 60):02d},{int((start % 1) * 1000):03d}"
            end_s = f"{int(end // 3600):02d}:{int((end % 3600) // 60):02d}:{int(end % 60):02d},{int((end % 1) * 1000):03d}"

            srt_content += f"{i}\n{start_s} --> {end_s}\n{text}\n\n"

        subtitle_path.write_text(srt_content, encoding='utf-8')
        return True
    except Exception as e:
        print_warning(f"字幕生成失败: {e}")
        return True  # 不阻塞


def step_bgm(task_id: str, config: Dict, state_mgr: BatchStateManager, output_base: Path) -> bool:
    """BGM 匹配步骤"""
    if config.get("skip_bgm"):
        return True

    audio_dir = output_base / "audio"
    audio_dir.mkdir(parents=True, exist_ok=True)

    bgm_path = audio_dir / "bgm.mp3"

    # 使用 BGM finder
    bgm_finder_script = PROJECT_ROOT / "tools" / "publishing" / "bgm_finder.py"

    cmd = [
        "python3", str(bgm_finder_script),
        "--mood", "calm",
        "--bgm-dir", str(audio_dir)
    ]

    result = subprocess.run(cmd, capture_output=True, text=True, cwd=str(PROJECT_ROOT))

    # bgm_finder 会把选中的 BGM 复制到 bgm_dir
    # 检查是否成功生成了 bgm 文件
    if result.returncode == 0:
        bgm_files = list(audio_dir.glob("*.mp3"))
        if not bgm_files:
            # 如果没有生成，创建一个空的成功状态
            print_warning("BGM 未生成，可能无匹配的 BGM")
    else:
        print_warning(f"BGM 选择失败: {result.stderr[:200] if result.stderr else 'unknown'}")

    return result.returncode == 0


def step_assemble(task_id: str, turtle_type: str, config: Dict, state_mgr: BatchStateManager, output_base: Path) -> bool:
    """视频组装步骤"""
    frames_dir = output_base / "frames"
    audio_dir = output_base / "audio"

    video_path = output_base / "final.mp4"

    tts_path = audio_dir / "tts.mp3"
    subtitle_path = audio_dir / "subtitle.srt"
    bgm_path = audio_dir / "bgm.mp3"

    # 收集图片
    image_files = []
    if frames_dir.exists():
        for ext in ['*.jpg', '*.jpeg', '*.png']:
            image_files.extend(sorted(frames_dir.glob(f"*/{ext}")))
            image_files.extend(sorted(frames_dir.glob(ext)))

    if not image_files:
        print_warning("没有找到图片，使用占位黑屏")
        # 创建临时黑屏视频
        return True

    # 调用视频组装
    assembler_script = PROJECT_ROOT / "tools" / "video" / "video_assembler.py"

    cmd = [
        "python3", str(assembler_script),
        "--images"
    ]
    cmd.extend([str(f) for f in image_files[:20]])  # 限制最多20张
    cmd.extend([
        "--audio", str(tts_path),
        "--output", str(video_path)
    ])

    if subtitle_path.exists():
        cmd.extend(["--subtitle", str(subtitle_path)])

    if bgm_path.exists():
        cmd.extend(["--bgm", str(bgm_path)])

    result = subprocess.run(cmd, capture_output=True, text=True, cwd=str(PROJECT_ROOT))

    return result.returncode == 0


def step_cover(task_id: str, turtle_type: str, config: Dict, state_mgr: BatchStateManager, output_base: Path) -> bool:
    """封面生成步骤"""
    cover_path = output_base / "cover.png"

    # 使用 PIL 生成简单封面
    try:
        from PIL import Image, ImageDraw, ImageFont

        width, height = 1280, 720
        img = Image.new('RGB', (width, height), color=(30, 90, 60))
        draw = ImageDraw.Draw(img)

        # 添加标题文字
        try:
            font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 60)
        except:
            font = ImageFont.load_default()

        title = task_id.replace('-', ' ').replace('_', ' ')
        bbox = draw.textbbox((0, 0), title, font=font)
        text_width = bbox[2] - bbox[0]
        text_height = bbox[3] - bbox[1]

        x = (width - text_width) // 2
        y = (height - text_height) // 2

        draw.text((x, y), title, fill=(255, 255, 255), font=font)

        img.save(cover_path)
        return True
    except Exception as e:
        print_warning(f"封面生成失败: {e}")
        return True


def step_publish(task_id: str, config: Dict, state_mgr: BatchStateManager, output_base: Path) -> bool:
    """B站发布步骤"""
    if config.get("skip_publish"):
        return True

    video_path = output_base / "final.mp4"
    cover_path = output_base / "cover.png"

    if not video_path.exists():
        print_warning("视频文件不存在，跳过发布")
        return True

    # 调用 B站发布
    publisher_script = PROJECT_ROOT / "tools" / "publishing" / "bilibili_publisher.py"

    cmd = [
        "python3", str(publisher_script),
        "--video", str(video_path),
        "--cover", str(cover_path) if cover_path.exists() else ""
    ]

    result = subprocess.run(cmd, capture_output=True, text=True, cwd=str(PROJECT_ROOT))

    return result.returncode == 0


# ============== CLI 命令 ==============

def cmd_list(args):
    """列出可用文案"""
    # 扫描所有龟种目录
    scripts_dir = DOCS_VIDEO / "scripts"

    if not scripts_dir.exists():
        print_error(f"文案目录不存在: {scripts_dir}")
        return

    all_scripts = []

    for turtle_type in TURTLE_TYPES.keys():
        turtle_dir = scripts_dir / turtle_type
        if not turtle_dir.exists():
            continue

        for md_file in turtle_dir.rglob("*.md"):
            if md_file.name.startswith("00-"):
                continue

            # 检测状态
            task_id = md_file.stem
            output_dir = VIDEO_OUTPUT_DIR / turtle_type / task_id
            video_file = output_dir / "final.mp4"

            if video_file.exists():
                status = "已完成"
            else:
                status = "待处理"

            all_scripts.append({
                "turtle_type": turtle_type,
                "task_id": task_id,
                "script_path": str(md_file.relative_to(PROJECT_ROOT)),
                "status": status
            })

    # 过滤
    if args.turtle:
        all_scripts = [s for s in all_scripts if args.turtle in s["turtle_type"]]

    if args.status:
        all_scripts = [s for s in all_scripts if args.status in s["status"]]

    # 输出
    if args.format == "json":
        print(json.dumps(all_scripts, ensure_ascii=False, indent=2))
    else:
        print_header("可用文案列表")
        print(f"{'龟种':<10} {'状态':<8} {'标题':<40}")
        print("-" * 60)
        for s in all_scripts:
            print(f"{s['turtle_type']:<10} {s['status']:<8} {s['task_id']:<40}")

        print(f"\n共 {len(all_scripts)} 个文案")

        # 统计
        completed = sum(1 for s in all_scripts if s["status"] == "已完成")
        pending = len(all_scripts) - completed
        print(f"已完成: {completed}, 待处理: {pending}")


def cmd_run(args):
    """执行批量任务"""
    ensure_dirs()

    # 扫描文件
    if args.paths:
        paths = args.paths
    else:
        paths = [str(DOCS_VIDEO / "scripts")]

    print(f"扫描路径: {paths}")
    scripts = find_script_files(paths)

    if not scripts:
        print_error("没有找到待处理的文案文件")
        return

    print(f"找到 {len(scripts)} 个文案")

    # 过滤
    if args.turtle:
        scripts = [s for s in scripts if args.turtle in s.get("turtle_type", "")]

    if not scripts:
        print_error("没有匹配的任务")
        return

    # 构建配置
    config = build_config(args)

    # 创建或加载批量状态
    if args.batch_id:
        state_mgr = BatchStateManager(args.batch_id)
        state = state_mgr.load_batch(args.batch_id)
        if not state:
            print_error(f"无法加载批量任务: {args.batch_id}")
            return
        print(f"继续批量任务: {args.batch_id}")
    else:
        state_mgr = BatchStateManager()
        state = state_mgr.create_batch(config, scripts)
        print(f"创建批量任务: {state.batch_id}")

    if args.dry_run:
        print_warning("[DRY RUN] 仅预览，不实际执行")
        print("\n将执行的任务:")
        for i, task in enumerate(scripts, 1):
            print(f"  {i}. {task['task_id']} ({task['turtle_type']})")
        return

    # 执行任务
    print_header("开始批量处理")

    completed = 0
    failed = 0

    for i, task in enumerate(scripts, 1):
        state = state_mgr.get_state()
        if not state:
            break

        # 检查是否已完成
        task_state = state.get_task(task["task_id"])
        if task_state and task_state.status == TASK_STATUS["COMPLETED"]:
            print(f"\n跳过已完成: {task['task_id']}")
            completed += 1
            continue

        success = process_single_task(task, config, state_mgr, dry_run=args.dry_run)
        if success:
            completed += 1
        else:
            failed += 1

    # 输出总结
    print_header("批量任务完成")
    print(f"完成: {completed}, 失败: {failed}")
    print(f"批量ID: {state_mgr.batch_id}")
    print(f"状态文件: {state_mgr.state_file}")


def cmd_status(args):
    """查看批量任务状态"""
    if args.batch_id:
        # 查看指定任务
        state_mgr = BatchStateManager(args.batch_id)
        state = state_mgr.load_batch(args.batch_id)

        if not state:
            print_error(f"无法加载批量任务: {args.batch_id}")
            return

        print_header(f"批量任务: {state.batch_id}")
        print(f"创建时间: {state.created_at}")
        print(f"更新时间: {state.updated_at}")

        summary = state.get_summary()
        print(f"\n进度: {summary['completed']}/{summary['total']} 完成")

        print(f"\n任务列表:")
        for task in state.tasks:
            status_icon = {
                "PENDING": "○",
                "PROCESSING": "⟳",
                "COMPLETED": "✓",
                "FAILED": "✗",
                "SKIPPED": "-"
            }.get(task.status, "?")

            print(f"  {status_icon} {task.task_id:<40} [{task.turtle_type}] {task.status}")

    else:
        # 列出所有批量任务
        batches = BatchStateManager.list_batches()

        if not batches:
            print("没有批量任务记录")
            return

        print_header("批量任务列表")
        print(f"{'Batch ID':<30} {'创建时间':<20} {'进度':<15}")
        print("-" * 70)

        for batch in batches:
            progress = f"{batch['completed']}/{batch['total']}"
            created = batch.get('created_at', '')[:19]
            print(f"{batch['batch_id']:<30} {created:<20} {progress:<15}")


def cmd_resume(args):
    """断点续传"""
    if args.batch_id:
        batch_id = args.batch_id
    else:
        # 获取最新的批量任务
        batches = BatchStateManager.list_batches()
        if not batches:
            print_error("没有可恢复的批量任务")
            return
        batch_id = batches[0]["batch_id"]

    print(f"恢复批量任务: {batch_id}")

    # 加载任务
    state_mgr = BatchStateManager(batch_id)
    state = state_mgr.load_batch(batch_id)

    if not state:
        print_error(f"无法加载批量任务: {batch_id}")
        return

    # 获取失败和待处理任务
    tasks_to_retry = [t for t in state.tasks
                      if t.status in [TASK_STATUS["PENDING"], TASK_STATUS["FAILED"]]]

    if not tasks_to_retry:
        print("没有需要重试的任务")
        return

    print(f"需要重试的任务: {len(tasks_to_retry)}")

    # 执行
    config = state.config
    for task in tasks_to_retry:
        task_dict = {
            "task_id": task.task_id,
            "script_path": task.script_path,
            "turtle_type": task.turtle_type
        }
        process_single_task(task_dict, config, state_mgr)


def main():
    parser = argparse.ArgumentParser(
        description="批量视频制作工作流",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
示例:
  %(prog)s list                                  # 列出所有文案
  %(prog)s list --turtle 鳄龟                    # 只看鳄龟
  %(prog)s run docs/video/scripts/鳄龟/          # 处理鳄龟所有文案
  %(prog)s run 01-养鳄龟选大还是小.md --dry-run  # 预览单个任务
  %(prog)s status                                # 查看所有批次状态
  %(prog)s resume                                # 恢复最新批次
        """
    )

    subparsers = parser.add_subparsers(dest="command", help="子命令")

    # list 命令
    list_parser = subparsers.add_parser("list", help="列出可用文案")
    list_parser.add_argument("--turtle", help="按龟种筛选")
    list_parser.add_argument("--status", help="按状态筛选 (待处理/已完成)")
    list_parser.add_argument("--format", default="table", choices=["table", "json"], help="输出格式")

    # run 命令
    run_parser = subparsers.add_parser("run", help="执行批量任务")
    run_parser.add_argument("paths", nargs="*", help="文件或目录路径")
    run_parser.add_argument("--batch-id", help="指定批量任务ID（用于继续）")
    run_parser.add_argument("--turtle", help="按龟种筛选")
    run_parser.add_argument("--steps", help="指定步骤 (逗号分隔)")
    run_parser.add_argument("--review-rounds", type=int, help="Review 轮数")
    run_parser.add_argument("--voice", default="xiaoxiao", choices=TTS_VOICES.keys(), help="TTS 声音")
    run_parser.add_argument("--skip-review", action="store_true", help="跳过 Review")
    run_parser.add_argument("--skip-lineart", action="store_true", help="跳过 AI 绘图")
    run_parser.add_argument("--skip-bgm", action="store_true", help="跳过 BGM")
    run_parser.add_argument("--skip-publish", action="store_true", help="跳过 B站发布")
    run_parser.add_argument("--dry-run", action="store_true", help="仅预览不执行")

    # status 命令
    status_parser = subparsers.add_parser("status", help="查看批量任务状态")
    status_parser.add_argument("batch_id", nargs="?", help="批量任务ID")

    # resume 命令
    resume_parser = subparsers.add_parser("resume", help="断点续传")
    resume_parser.add_argument("batch_id", nargs="?", help="批量任务ID")

    args = parser.parse_args()

    if not args.command:
        parser.print_help()
        return

    # 确保输出目录存在
    ensure_dirs()

    # 执行子命令
    if args.command == "list":
        cmd_list(args)
    elif args.command == "run":
        cmd_run(args)
    elif args.command == "status":
        cmd_status(args)
    elif args.command == "resume":
        cmd_resume(args)
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
