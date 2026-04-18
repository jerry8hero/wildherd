#!/usr/bin/env python3
"""
龟类图片素材收集工具

从 Pexels 免费下载龟类高清图片，用于视频制作

使用方法:
    python3 turtle_image_collector.py              # 交互式下载
    python3 turtle_image_collector.py --search "turtle" --count 20
    python3 turtle_image_collector.py --search "turtle aquarium" --count 50
"""

import argparse
import os
import sys
from pathlib import Path
from typing import List, Optional
import requests
import urllib.request
import time
import random

# 素材保存目录
# 优先级：环境变量 > 项目默认目录
PROJECT_ROOT = Path(__file__).parent.parent.parent
ASSETS_DIR = PROJECT_ROOT / "assets"
TURTLE_IMAGES_DIR = Path(os.environ.get(
    "WILDHIRD_TURTLE_IMAGES_DIR",
    str(ASSETS_DIR / "turtle-images")
))

# Pexels API (免费注册获取)
# https://www.pexels.com/api/
PEXELS_API_KEY = os.environ.get("PEXELS_API_KEY", "")

# Pexels 搜索关键词
DEFAULT_KEYWORDS = [
    "turtle",
    "aquarium turtle",
    "pet turtle",
    "red eared slider",
    "tortoise",
    "sea turtle",
    "water turtle",
    "turtle shell",
]


def ensure_dir():
    """确保目录存在"""
    TURTLE_IMAGES_DIR.mkdir(parents=True, exist_ok=True)
    print(f"素材目录: {TURTLE_IMAGES_DIR}")


def search_pexels(keyword: str, per_page: int = 15) -> Optional[List[dict]]:
    """搜索 Pexels 图片"""
    if not PEXELS_API_KEY:
        print("请设置 PEXELS_API_KEY 环境变量")
        print("获取方式: https://www.pexels.com/api/")
        return None

    url = "https://api.pexels.com/v1/search"
    headers = {"Authorization": PEXELS_API_KEY}
    params = {
        "query": keyword,
        "per_page": per_page,
        "orientation": "landscape"
    }

    try:
        response = requests.get(url, headers=headers, params=params, timeout=30)
        if response.status_code == 200:
            data = response.json()
            return data.get("photos", [])
        else:
            print(f"搜索失败: {response.status_code}")
            return None
    except Exception as e:
        print(f"请求异常: {e}")
        return None


def download_image(url: str, output_path: Path) -> bool:
    """下载单张图片"""
    try:
        headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        }
        request = urllib.request.Request(url, headers=headers)
        with urllib.request.urlopen(request, timeout=30) as response:
            data = response.read()
            output_path.write_bytes(data)
        return True
    except Exception as e:
        print(f"下载失败: {e}")
        return False


def download_batch(photos: List[dict], output_dir: Path, prefix: str = "") -> int:
    """批量下载图片"""
    success_count = 0
    for i, photo in enumerate(photos, 1):
        photo_id = photo.get("id", i)
        # 获取大图 URL
        src = photo.get("src", {})
        original_url = src.get("original") or src.get("large2x") or src.get("large")

        if not original_url:
            continue

        ext = os.path.splitext(original_url)[1] or ".jpg"
        filename = f"{prefix}{photo_id}{ext}" if prefix else f"{photo_id}{ext}"
        output_path = output_dir / filename

        print(f"  [{i}/{len(photos)}] 下载: {filename}", end=" ... ")

        if download_image(original_url, output_path):
            print("✓")
            success_count += 1
        else:
            print("✗")

        # 避免请求过快
        time.sleep(0.3 + random.random() * 0.3)

    return success_count


def interactive_download():
    """交互式下载"""
    print("=" * 60)
    print("龟类图片素材收集工具")
    print("=" * 60)

    # 选择关键词
    print("\n可用关键词:")
    for i, kw in enumerate(DEFAULT_KEYWORDS, 1):
        print(f"  {i}. {kw}")

    print("\n输入关键词编号（多个用逗号分隔），或直接输入自定义关键词:")
    print("(直接回车使用默认: turtle)")

    choice = input("> ").strip()

    if not choice:
        keywords = ["turtle"]
    elif choice.isdigit():
        indices = [int(x.strip()) for x in choice.split(",")]
        keywords = [DEFAULT_KEYWORDS[i-1] for i in indices if 0 < i <= len(DEFAULT_KEYWORDS)]
        if not keywords:
            keywords = ["turtle"]
    else:
        keywords = [choice]

    print(f"\n使用关键词: {keywords}")

    # 选择数量
    print("\n输入每关键词下载数量（直接回车默认15）:")
    count_input = input("> ").strip()
    per_page = int(count_input) if count_input.isdigit() else 15
    per_page = min(per_page, 80)  # Pexels 免费版限制

    # 搜索并下载
    total_success = 0

    for keyword in keywords:
        print(f"\n搜索: {keyword}")

        photos = search_pexels(keyword, per_page)
        if not photos:
            print(f"  搜索 '{keyword}' 失败或无结果")
            continue

        print(f"  找到 {len(photos)} 张图片，开始下载...")

        prefix = keyword.replace(" ", "_") + "_"
        success = download_batch(photos, TURTLE_IMAGES_DIR, prefix)
        total_success += success

        print(f"  {keyword}: 成功 {success}/{len(photos)}")

    print("\n" + "=" * 60)
    print(f"下载完成! 共获得 {total_success} 张图片")
    print(f"素材目录: {TURTLE_IMAGES_DIR}")
    print("=" * 60)


def main():
    parser = argparse.ArgumentParser(
        description="龟类图片素材收集工具 - 从 Pexels 下载免费图片",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
示例:
  %(prog)s --search turtle --count 20
  %(prog)s --search "sea turtle" --count 30
  %(prog)s --list-keywords

环境变量:
  PEXELS_API_KEY - 你的 Pexels API 密钥

获取 API Key:
  1. 访问 https://www.pexels.com/api/
  2. 注册账号（免费）
  3. 创建 API Key
  4. 设置环境变量: export PEXELS_API_KEY="你的密钥"
        """
    )

    parser.add_argument("--search", "-s", help="搜索关键词")
    parser.add_argument("--count", "-c", type=int, default=15, help="每关键词下载数量 (默认15)")
    parser.add_argument("--list-keywords", "-l", action="store_true", help="列出可用关键词")
    parser.add_argument("--ensure-dir", action="store_true", help="确保素材目录存在")
    parser.add_argument("--status", action="store_true", help="查看素材库状态")

    args = parser.parse_args()

    ensure_dir()

    if args.list_keywords:
        print("可用搜索关键词:")
        for i, kw in enumerate(DEFAULT_KEYWORDS, 1):
            print(f"  {i}. {kw}")
        return

    if args.status:
        images = list(TURTLE_IMAGES_DIR.glob("*.jpg")) + \
                 list(TURTLE_IMAGES_DIR.glob("*.jpeg")) + \
                 list(TURTLE_IMAGES_DIR.glob("*.png"))
        total_size = sum(f.stat().st_size for f in images)

        print(f"素材库状态:")
        print(f"  图片数量: {len(images)}")
        print(f"  总大小: {total_size / 1024 / 1024:.1f} MB")
        print(f"  目录: {TURTLE_IMAGES_DIR}")

        if images:
            print(f"\n最近添加:")
            for img in sorted(images, key=lambda x: x.stat().st_mtime, reverse=True)[:5]:
                print(f"  - {img.name}")
        return

    if args.ensure_dir:
        print(f"素材目录已准备: {TURTLE_IMAGES_DIR}")
        return

    if not args.search:
        # 交互模式
        if not PEXELS_API_KEY:
            print("请先设置 PEXELS_API_KEY 环境变量:")
            print('  export PEXELS_API_KEY="你的密钥"')
            print("\n或者直接指定搜索关键词:")
            print("  python3 turtle_image_collector.py --search turtle --count 20")
            print("\n获取 API Key: https://www.pexels.com/api/")
            return

        interactive_download()
        return

    # 命令行模式
    if not PEXELS_API_KEY:
        print("错误: 需要设置 PEXELS_API_KEY 环境变量")
        return

    print(f"搜索: {args.search}, 下载数量: {args.count}")

    photos = search_pexels(args.search, args.count)
    if not photos:
        print("搜索失败")
        return

    print(f"找到 {len(photos)} 张图片，开始下载...")

    prefix = args.search.replace(" ", "_") + "_"
    success = download_batch(photos, TURTLE_IMAGES_DIR, prefix)

    print(f"\n完成! 成功下载 {success}/{len(photos)} 张图片")
    print(f"保存位置: {TURTLE_IMAGES_DIR}")


if __name__ == "__main__":
    main()
