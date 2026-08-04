#!/usr/bin/env python3
"""
视频脚本批量管理工具
支持批量重命名、状态更新、导出等操作

使用方法：
    # 查看报告
    python tools/scripts_manager.py report

    # 更新状态
    python tools/scripts_manager.py status 草龟 1 published --url https://www.bilibili.com/video/BV1xxxxxx

    # 批量重命名（预览）
    python tools/scripts_manager.py rename 草龟

    # 批量重命名（执行）
    python tools/scripts_manager.py rename 草龟 --execute

    # 导出物种脚本
    python tools/scripts_manager.py export 草龟

    # 导出到指定目录
    python tools/scripts_manager.py export 草龟 -o ./output
"""

import json
import shutil
from pathlib import Path
from datetime import datetime
import argparse
import sys

INDEX_FILE = Path(__file__).parent.parent / "docs" / "video" / "scripts" / "index.json"
SCRIPTS_DIR = INDEX_FILE.parent


class ScriptsManager:
    """脚本管理器"""

    def __init__(self):
        self.index = self._load_index()

    def _load_index(self) -> dict:
        """加载索引"""
        if not INDEX_FILE.exists():
            print("❌ 索引不存在，请先运行: python3 tools/scripts_indexer.py")
            sys.exit(1)
        with open(INDEX_FILE, 'r', encoding='utf-8') as f:
            return json.load(f)

    def _save_index(self):
        """保存索引"""
        self.index["generated_at"] = datetime.now().isoformat()
        with open(INDEX_FILE, 'w', encoding='utf-8') as f:
            json.dump(self.index, f, ensure_ascii=False, indent=2)

    def _find_script(self, species: str, episode: int) -> dict:
        """查找指定脚本"""
        for script in self.index["scripts"]:
            if script["species"] == species and script.get("episode") == episode:
                return script
        return None

    def report(self):
        """生成统计报告"""
        stats = self.index["stats"]
        species_stats = self.index["species_stats"]

        print("\n" + "=" * 60)
        print("📊 视频脚本统计报告")
        print("=" * 60)

        print(f"\n📁 总体统计:")
        print(f"   总文件数: {stats['total_files']}")
        print(f"   物种数: {stats['species_count']}")

        print(f"\n📂 文件类型分布:")
        for ft, count in sorted(stats["by_type"].items()):
            print(f"   - {ft}: {count}")

        print(f"\n📈 物种排行 (Top 15):")
        sorted_species = sorted(
            species_stats.items(),
            key=lambda x: x[1]["total"],
            reverse=True,
        )[:15]
        for i, (species, s) in enumerate(sorted_species, 1):
            types = ", ".join(f"{k}:{v}" for k, v in s.get("by_type", {}).items())
            print(f"   {i:2d}. {species}: {s['total']} 个文件 ({types})")

        print("\n" + "=" * 60)

    def update_status(self, species: str, episode: int, status: str, bilibili_url: str = None):
        """更新脚本状态"""
        script = self._find_script(species, episode)
        if not script:
            print(f"❌ 未找到: {species} 第 {episode} 集")
            return

        script["status"] = status
        if bilibili_url:
            script["bilibili_url"] = bilibili_url
            script["published_at"] = datetime.now().isoformat()

        self._save_index()
        print(f"✅ 已更新: {species} {episode:02d} → {status}")
        if bilibili_url:
            print(f"   URL: {bilibili_url}")

    def rename_preview(self, species: str):
        """批量重命名预览"""
        scripts = [s for s in self.index["scripts"] if s["species"] == species]
        if not scripts:
            print(f"❌ 未找到物种: {species}")
            return

        print(f"\n📁 重命名预览: {species}")
        print("-" * 80)
        print(f"{'当前文件名':<40} → {'新文件名':<40}")
        print("-" * 80)

        count = 0
        for script in sorted(scripts, key=lambda x: x.get("episode") or 0):
            old_path = SCRIPTS_DIR / script["relative_path"]
            if not old_path.exists():
                continue

            # 生成新文件名
            episode = script.get("episode", 0)
            title = script.get("title", "unknown")
            file_type = script.get("file_type", "script")

            # 根据类型生成新文件名
            if file_type == "script":
                new_name = f"{episode:02d}-{title}.md"
            elif file_type == "bilibili_publish":
                new_name = f"{episode:02d}-B站发布内容.md"
            elif file_type == "jianying":
                new_name = f"{episode:02d}-{title}_剪映版.md"
            elif file_type == "xiaohongshu":
                new_name = f"{episode:02d}-{title}_小红书.md"
            else:
                new_name = old_path.name

            if old_path.name != new_name:
                print(f"{old_path.name:<40} → {new_name:<40}")
                count += 1

        print("-" * 80)
        print(f"共 {count} 个文件需要重命名")
        print("\n⚠️  预览模式，未实际执行。添加 --execute 参数执行")

    def rename_execute(self, species: str):
        """执行批量重命名"""
        scripts = [s for s in self.index["scripts"] if s["species"] == species]
        if not scripts:
            print(f"❌ 未找到物种: {species}")
            return

        print(f"\n📁 执行重命名: {species}")

        count = 0
        for script in sorted(scripts, key=lambda x: x.get("episode") or 0):
            old_path = SCRIPTS_DIR / script["relative_path"]
            if not old_path.exists():
                continue

            # 生成新文件名
            episode = script.get("episode", 0)
            title = script.get("title", "unknown")
            file_type = script.get("file_type", "script")

            if file_type == "script":
                new_name = f"{episode:02d}-{title}.md"
            elif file_type == "bilibili_publish":
                new_name = f"{episode:02d}-B站发布内容.md"
            elif file_type == "jianying":
                new_name = f"{episode:02d}-{title}_剪映版.md"
            elif file_type == "xiaohongshu":
                new_name = f"{episode:02d}-{title}_小红书.md"
            else:
                new_name = old_path.name

            new_path = old_path.parent / new_name

            if old_path != new_path and not new_path.exists():
                print(f"  {old_path.name} → {new_name}")
                old_path.rename(new_path)
                # 更新索引路径
                script["relative_path"] = str(new_path.relative_to(SCRIPTS_DIR))
                count += 1

        self._save_index()
        print(f"\n✅ 已重命名 {count} 个文件")

    def export_by_species(self, species: str, output_dir: Path = None):
        """按物种导出脚本"""
        scripts = [s for s in self.index["scripts"] if s["species"] == species]
        if not scripts:
            print(f"❌ 未找到物种: {species}")
            return

        if output_dir is None:
            output_dir = Path(f"./export_{species}")

        output_dir.mkdir(parents=True, exist_ok=True)

        print(f"\n📤 导出: {species}")
        print(f"   目标目录: {output_dir}")

        count = 0
        for script in scripts:
            src = SCRIPTS_DIR / script["relative_path"]
            if src.exists():
                dst = output_dir / src.name
                shutil.copy(src, dst)
                count += 1

        print(f"✅ 已导出 {count} 个文件")

    def list_species(self):
        """列出所有物种"""
        species_stats = self.index["species_stats"]

        print("\n📋 物种列表:")
        print("-" * 50)
        print(f"{'物种':<20} {'文件数':<10} {'类型'}")
        print("-" * 50)

        for species, stats in sorted(species_stats.items()):
            types = ", ".join(f"{k}:{v}" for k, v in stats.get("by_type", {}).items())
            print(f"{species:<20} {stats['total']:<10} {types}")

        print("-" * 50)
        print(f"共 {len(species_stats)} 个物种")


def main():
    parser = argparse.ArgumentParser(
        description="视频脚本批量管理工具",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
示例:
  %(prog)s report                     # 显示统计报告
  %(prog)s list                       # 列出所有物种
  %(prog)s status 草龟 1 published    # 更新状态
  %(prog)s status 草龟 1 published --url https://...
  %(prog)s rename 草龟                # 预览重命名
  %(prog)s rename 草龟 --execute      # 执行重命名
  %(prog)s export 草龟                # 导出草龟脚本
  %(prog)s export 草龟 -o ./output    # 导出到指定目录
        """,
    )

    subparsers = parser.add_subparsers(dest="command")

    # report 子命令
    subparsers.add_parser("report", help="显示统计报告")

    # list 子命令
    subparsers.add_parser("list", help="列出所有物种")

    # status 子命令
    status_parser = subparsers.add_parser("status", help="更新脚本状态")
    status_parser.add_argument("species", help="物种名称")
    status_parser.add_argument("episode", type=int, help="集数")
    status_parser.add_argument("status", choices=["draft", "published", "in_progress", "deprecated"], help="新状态")
    status_parser.add_argument("--url", help="B站链接")

    # rename 子命令
    rename_parser = subparsers.add_parser("rename", help="批量重命名")
    rename_parser.add_argument("species", help="物种名称")
    rename_parser.add_argument("--execute", action="store_true", help="执行重命名（默认仅预览）")

    # export 子命令
    export_parser = subparsers.add_parser("export", help="导出脚本")
    export_parser.add_argument("species", help="物种名称")
    export_parser.add_argument("-o", "--output", help="输出目录")

    args = parser.parse_args()
    manager = ScriptsManager()

    if args.command == "report":
        manager.report()
    elif args.command == "list":
        manager.list_species()
    elif args.command == "status":
        manager.update_status(args.species, args.episode, args.status, args.url)
    elif args.command == "rename":
        if args.execute:
            manager.rename_execute(args.species)
        else:
            manager.rename_preview(args.species)
    elif args.command == "export":
        output = Path(args.output) if args.output else None
        manager.export_by_species(args.species, output)
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
