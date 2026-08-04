#!/usr/bin/env python3
"""
视频脚本搜索工具
基于 index.json 进行多维度搜索

使用方法：
    # 搜索草龟所有脚本
    python tools/scripts_search.py -s 草龟

    # 搜索包含"繁殖"关键词的脚本
    python tools/scripts_search.py -k 繁殖

    # 搜索草龟 1-10 集的脚本
    python tools/scripts_search.py -s 草龟 --min 1 --max 10

    # 搜索所有 B站发布内容
    python tools/scripts_search.py -t bilibili_publish

    # 搜索冷到你唔信第五册
    python tools/scripts_search.py -s 冷到你唔信 -v 第五册
"""

import json
import sys
from pathlib import Path
from typing import List, Optional
import argparse

INDEX_FILE = Path(__file__).parent.parent / "docs" / "video" / "scripts" / "index.json"


def load_index() -> dict:
    """加载索引"""
    if not INDEX_FILE.exists():
        print("❌ 索引不存在，请先运行: python3 tools/scripts_indexer.py")
        sys.exit(1)

    with open(INDEX_FILE, 'r', encoding='utf-8') as f:
        return json.load(f)


def search_scripts(
    species: Optional[str] = None,
    keyword: Optional[str] = None,
    status: Optional[str] = None,
    episode_min: Optional[int] = None,
    episode_max: Optional[int] = None,
    file_type: Optional[str] = None,
    volume: Optional[str] = None,
    limit: int = 20,
) -> List[dict]:
    """多维度搜索脚本"""
    index = load_index()
    results = index["scripts"]

    # 物种筛选（模糊匹配）
    if species:
        species_lower = species.lower()
        results = [s for s in results if species_lower in s["species"].lower()]

    # 册子筛选（仅冷到你唔信）
    if volume:
        volume_lower = volume.lower()
        results = [s for s in results if volume_lower in s.get("volume", "").lower()]

    # 关键词搜索（标题和路径）
    if keyword:
        keyword_lower = keyword.lower()
        results = [
            s for s in results
            if keyword_lower in (s.get("title") or "").lower()
            or keyword_lower in s.get("relative_path", "").lower()
        ]

    # 状态筛选
    if status:
        results = [s for s in results if s.get("status") == status]

    # 集数范围
    if episode_min is not None:
        results = [s for s in results if s.get("episode") is not None and s["episode"] >= episode_min]
    if episode_max is not None:
        results = [s for s in results if s.get("episode") is not None and s["episode"] <= episode_max]

    # 文件类型
    if file_type:
        results = [s for s in results if s.get("file_type") == file_type]

    # 限制结果数量
    return results[:limit]


def print_results(results: List[dict], verbose: bool = False):
    """打印搜索结果"""
    if not results:
        print("未找到匹配结果")
        return

    print(f"\n找到 {len(results)} 个结果:\n")
    print("-" * 100)
    print(f"{'物种':<10} {'册子':<12} {'集数':<6} {'类型':<15} {'标题':<35} {'字数':<8}")
    print("-" * 100)

    for r in results:
        species = r.get("species", "?")[:8]
        volume = r.get("volume", "")[:10] or "-"
        episode = r.get("episode", "-")
        file_type = r.get("file_type", "?")[:12]
        title = (r.get("title") or "?")[:33]
        word_count = r.get("word_count", 0)

        print(f"{species:<10} {volume:<12} {str(episode):<6} {file_type:<15} {title:<35} {word_count:<8}")

        if verbose:
            print(f"           路径: {r.get('relative_path', '?')}")
            print(f"           修改: {r.get('modified_at', '?')[:10]}")
            if r.get("tags"):
                print(f"           标签: {', '.join(r['tags'])}")
            print()

    print("-" * 100)


def print_stats(species: Optional[str] = None):
    """打印统计信息"""
    index = load_index()

    if species:
        # 单个物种统计
        stats = index["species_stats"].get(species)
        if not stats:
            print(f"未找到物种: {species}")
            return

        print(f"\n📊 {species} 统计:")
        print(f"   总文件数: {stats['total']}")
        print(f"   文件类型分布:")
        for ft, count in stats.get("by_type", {}).items():
            print(f"     - {ft}: {count}")
    else:
        # 总体统计
        print(f"\n📊 总体统计:")
        print(f"   总文件数: {index['stats']['total_files']}")
        print(f"   物种数: {index['stats']['species_count']}")
        print(f"   文件类型分布:")
        for ft, count in index['stats']['by_type'].items():
            print(f"     - {ft}: {count}")

        print(f"\n📈 Top 10 物种:")
        sorted_species = sorted(
            index["species_stats"].items(),
            key=lambda x: x[1]["total"],
            reverse=True,
        )[:10]
        for species, stats in sorted_species:
            print(f"   {species}: {stats['total']} 个文件")


def main():
    parser = argparse.ArgumentParser(
        description="视频脚本搜索工具",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
示例:
  %(prog)s -s 草龟                    # 搜索草龟所有脚本
  %(prog)s -k 繁殖                    # 搜索包含"繁殖"的脚本
  %(prog)s -s 草龟 --min 1 --max 10  # 搜索草龟 1-10 集
  %(prog)s -t bilibili_publish        # 搜索所有 B站发布内容
  %(prog)s --stats                    # 显示统计信息
  %(prog)s --stats -s 草龟            # 显示草龟统计
        """,
    )

    parser.add_argument("-s", "--species", help="物种名称（模糊匹配）")
    parser.add_argument("-k", "--keyword", help="关键词（搜索标题和路径）")
    parser.add_argument("-t", "--type", choices=["script", "bilibili_publish", "jianying", "xiaohongshu", "cover_prompt"], help="文件类型")
    parser.add_argument("-v", "--volume", help="册子名称（仅冷到你唔信）")
    parser.add_argument("--min", type=int, help="最小集数")
    parser.add_argument("--max", type=int, help="最大集数")
    parser.add_argument("-l", "--limit", type=int, default=20, help="结果数量限制（默认 20）")
    parser.add_argument("--stats", action="store_true", help="显示统计信息")
    parser.add_argument("--verbose", action="store_true", help="显示详细信息")

    args = parser.parse_args()

    if args.stats:
        print_stats(args.species)
        return

    results = search_scripts(
        species=args.species,
        keyword=args.keyword,
        file_type=args.type,
        volume=args.volume,
        episode_min=args.min,
        episode_max=args.max,
        limit=args.limit,
    )

    print_results(results, verbose=args.verbose)


if __name__ == "__main__":
    main()
