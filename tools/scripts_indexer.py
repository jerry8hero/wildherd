#!/usr/bin/env python3
"""
视频脚本索引生成器
扫描 docs/video/scripts/ 目录，生成统一索引 JSON

使用方法：
    python tools/scripts_indexer.py

输出：
    docs/video/scripts/index.json
"""

import json
import os
import re
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Optional

# 路径配置
SCRIPTS_DIR = Path(__file__).parent.parent / "docs" / "video" / "scripts"
INDEX_FILE = SCRIPTS_DIR / "index.json"

# 文件类型检测关键词
FILE_TYPE_KEYWORDS = {
    "bilibili_publish": ["B站发布内容", "bilibili"],
    "jianying": ["剪映版", "剪映"],
    "xiaohongshu": ["小红书", "红书"],
    "douyin": ["抖音"],
    "cover_prompt": ["封面提示词", "封面", "文生图提示词"],
    "publish_order": ["发布顺序", "排期"],
}

# 忽略的文件/目录
IGNORE_PATTERNS = [
    "index.json",
    "发布顺序.md",
    "发布计划.md",
    "物种图片搜索列表.md",
    "README.md",
]

# 忽略的目录（归档/备份）
IGNORE_DIRS = [
    "_archive",
    "粤语文案_backup",
    "_off-topic",
]


def parse_filename(filename: str) -> dict:
    """
    解析文件名，提取序号、标题、类型

    示例：
        01-养草龟需要准备什么.md → {"episode": 1, "title": "养草龟需要准备什么", "type": "script"}
        01-B站发布内容.md → {"episode": 1, "title": null, "type": "bilibili_publish"}
        01-养草龟需要准备什么_剪映版.md → {"episode": 1, "title": "养草龟需要准备什么", "type": "jianying"}
    """
    # 移除 .md 后缀
    name = filename.replace('.md', '')

    result = {
        "filename": filename,
        "file_type": "script",  # 默认为脚本
        "episode": None,
        "title": None,
    }

    # 检测文件类型（按优先级）
    for file_type, keywords in FILE_TYPE_KEYWORDS.items():
        for keyword in keywords:
            if keyword in name:
                result["file_type"] = file_type
                # 移除类型关键词
                name = name.replace(f"-{keyword}", "").replace(f"_{keyword}", "").replace(keyword, "")
                break
        if result["file_type"] != "script":
            break

    # 提取序号和标题
    # 匹配模式：数字 + 分隔符 + 标题
    match = re.match(r'^(\d+)[\-_](.+)$', name)
    if match:
        result["episode"] = int(match.group(1))
        result["title"] = match.group(2).strip()
    elif name.isdigit():
        # 纯数字文件名
        result["episode"] = int(name)

    return result


def extract_tags(title: str) -> List[str]:
    """从标题提取标签"""
    if not title:
        return []

    tags = []
    # 常见关键词
    keywords = [
        "入门", "新手", "进阶", "繁殖", "冬眠", "喂食", "喂养",
        "疾病", "防治", "健康", "挑选", "鉴别", "品相", "价格",
        "造景", "混养", "互动", "训练", "变异", "基因",
        "急救", "调理", "恢复", "误区", "避坑",
    ]

    for kw in keywords:
        if kw in title:
            tags.append(kw)

    return tags


def scan_species(species_dir: Path) -> List[dict]:
    """
    扫描单个物种目录，返回所有脚本信息

    Args:
        species_dir: 物种目录路径

    Returns:
        脚本信息列表
    """
    scripts = []
    species = species_dir.name

    # 跳过特殊目录
    if species.startswith('_') or species == '全七册':
        return []

    for md_file in sorted(species_dir.glob("*.md")):
        # 跳过忽略的文件
        if md_file.name in IGNORE_PATTERNS:
            continue

        # 解析文件名
        parsed = parse_filename(md_file.name)

        # 计算字数
        try:
            content = md_file.read_text(encoding='utf-8')
            word_count = len(content)
        except Exception:
            word_count = 0

        # 提取标签
        tags = extract_tags(parsed.get("title", ""))

        scripts.append({
            "species": species,
            "episode": parsed["episode"],
            "title": parsed["title"],
            "file_type": parsed["file_type"],
            "relative_path": str(md_file.relative_to(SCRIPTS_DIR)),
            "word_count": word_count,
            "tags": tags,
            "modified_at": datetime.fromtimestamp(md_file.stat().st_mtime).isoformat(),
        })

    return scripts


def scan_cold_knowledge_volume(volume_dir: Path, species: str) -> List[dict]:
    """
    扫描单个册子目录

    结构：
        第五册-鸟类/
            002-喜鹊/
                002-喜鹊_视频文案_粤语.md
                002-喜鹊_视频文案.md
            003-乌鸦/
                ...
    """
    scripts = []

    for species_dir in sorted(volume_dir.iterdir()):
        # 跳过非目录和忽略的目录
        if not species_dir.is_dir():
            continue
        if species_dir.name.startswith('_') or species_dir.name in IGNORE_DIRS:
            continue
            continue

        # 解析物种目录名（如 "002-喜鹊"）
        species_match = re.match(r'^(\d+)[\-_](.+)$', species_dir.name)
        species_name = species_match.group(2) if species_match else species_dir.name
        species_episode = int(species_match.group(1)) if species_match else None

        # 扫描该物种目录下的所有脚本
        for md_file in sorted(species_dir.glob("*.md")):
            if md_file.name in IGNORE_PATTERNS:
                continue

            parsed = parse_filename(md_file.name)

            try:
                content = md_file.read_text(encoding='utf-8')
                word_count = len(content)
            except Exception:
                word_count = 0

            tags = extract_tags(parsed.get("title", ""))

            scripts.append({
                "species": species,
                "volume": volume_dir.name,
                "species_name": species_name,
                "episode": species_episode or parsed["episode"],
                "title": parsed.get("title") or species_name,
                "file_type": parsed["file_type"],
                "relative_path": str(md_file.relative_to(SCRIPTS_DIR)),
                "word_count": word_count,
                "tags": tags,
                "modified_at": datetime.fromtimestamp(md_file.stat().st_mtime).isoformat(),
            })

    return scripts


def scan_cold_knowledge(species_dir: Path) -> List[dict]:
    """
    扫描冷到你唔信目录（特殊处理多层结构）

    结构：
        冷到你唔信/
            第一册-哺乳动物/       ← 根目录下的册子
                001-物种名/
                    脚本.md
            全七册/
                _archive/           ← 归档的册子
                    第一册-哺乳动物/
                第一册-哺乳动物/    ← 全七册下的册子
    """
    scripts = []
    species = "冷到你唔信"

    # 收集所有册子目录
    volume_dirs = []

    # 1. 检查根目录下的册子
    for d in species_dir.iterdir():
        if d.is_dir() and d.name.startswith("第") and "册" in d.name:
            volume_dirs.append(d)

    # 2. 检查全七册目录
    base_path = species_dir / "全七册"
    if base_path.exists():
        for d in base_path.iterdir():
            if d.is_dir() and not d.name.startswith('_') and d.name != "_archive":
                volume_dirs.append(d)

        # 3. 检查 _archive 目录
        archive_path = base_path / "_archive"
        if archive_path.exists():
            for d in archive_path.iterdir():
                if d.is_dir() and not d.name.startswith('_'):
                    volume_dirs.append(d)

    # 扫描所有册子
    for volume_dir in sorted(set(volume_dirs)):
        print(f"    📕 {volume_dir.name}...")
        volume_scripts = scan_cold_knowledge_volume(volume_dir, species)
        scripts.extend(volume_scripts)

    return scripts


def build_index() -> dict:
    """构建完整索引"""
    print(f"📂 扫描目录: {SCRIPTS_DIR}")

    all_scripts = []
    species_stats = {}

    # 获取所有物种目录（跳过忽略的目录）
    species_dirs = [d for d in SCRIPTS_DIR.iterdir() if d.is_dir() and d.name not in IGNORE_DIRS]

    for species_dir in sorted(species_dirs):
        species = species_dir.name

        # 特殊处理冷到你唔信
        if species == "冷到你唔信":
            print(f"  📁 {species} (多层结构)...")
            scripts = scan_cold_knowledge(species_dir)
        else:
            print(f"  📁 {species}...")
            scripts = scan_species(species_dir)

        all_scripts.extend(scripts)

        # 统计信息
        if scripts:
            species_stats[species] = {
                "total": len(scripts),
                "by_type": {},
            }
            for s in scripts:
                ft = s["file_type"]
                species_stats[species]["by_type"][ft] = species_stats[species]["by_type"].get(ft, 0) + 1

    # 按物种和集数排序
    all_scripts.sort(key=lambda x: (x["species"], x.get("volume", ""), x["episode"] or 0))

    # 总体统计
    total_stats = {
        "total_files": len(all_scripts),
        "species_count": len(species_stats),
        "by_type": {},
    }
    for s in all_scripts:
        ft = s["file_type"]
        total_stats["by_type"][ft] = total_stats["by_type"].get(ft, 0) + 1

    # 构建索引
    index = {
        "version": "1.0",
        "generated_at": datetime.now().isoformat(),
        "stats": total_stats,
        "species_stats": species_stats,
        "scripts": all_scripts,
    }

    # 保存索引
    INDEX_FILE.write_text(json.dumps(index, ensure_ascii=False, indent=2))

    # 打印摘要
    print(f"\n✅ 索引已生成: {INDEX_FILE}")
    print(f"   总文件数: {total_stats['total_files']}")
    print(f"   物种数: {total_stats['species_count']}")
    print(f"   文件类型分布:")
    for ft, count in sorted(total_stats["by_type"].items()):
        print(f"     - {ft}: {count}")

    return index


def main():
    """主函数"""
    build_index()


if __name__ == "__main__":
    main()
