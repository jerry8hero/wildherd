#!/usr/bin/env python3
"""
内容审核工作流管理系统

功能：
- 管理视频脚本的审核状态
- 追踪审核历史
- 支持多级审核流程

状态流转：
    草稿(draft) → 待审核(pending) → 审核中(reviewing) → 需要修改(changes_requested)
         ↑                                                              ↓
         ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← (approved) ← ←
                                                                                    ↓
                                                                                 已发布(published)

用法:
    python3 review_workflow.py submit <文件路径>          # 提交审核
    python3 review_workflow.py status <文件路径>           # 查看状态
    python3 review_workflow.py approve <文件路径>          # 批准发布
    python3 review_workflow.py reject <文件路径> -m "原因"  # 要求修改
    python3 review_workflow.py list                        # 列出所有审核项目
    python3 review_workflow.py history <文件路径>          # 查看审核历史
"""

import os
import sys
import json
import yaml
import argparse
from pathlib import Path
from datetime import datetime
from typing import Optional, List, Dict, Any
from enum import Enum


# 审核状态枚举
class ReviewStatus(Enum):
    DRAFT = "draft"           # 草稿
    PENDING = "pending"        # 待审核
    REVIEWING = "reviewing"    # 审核中
    CHANGES_REQUESTED = "changes_requested"  # 需要修改
    APPROVED = "approved"      # 已批准
    PUBLISHED = "published"   # 已发布


# 状态中文描述
STATUS_CHINESE = {
    "draft": "草稿",
    "pending": "待审核",
    "reviewing": "审核中",
    "changes_requested": "需要修改",
    "approved": "已批准",
    "published": "已发布"
}

# 颜色配置（终端输出）
COLORS = {
    "red": "\033[91m",
    "green": "\033[92m",
    "yellow": "\033[93m",
    "blue": "\033[94m",
    "purple": "\033[95m",
    "end": "\033[0m"
}


def colored(text: str, color: str) -> str:
    """给文本添加颜色"""
    return f"{COLORS.get(color, '')}{text}{COLORS['end']}"


# 配置路径
SCRIPT_DIR = Path(__file__).parent.parent
REVIEW_DB_FILE = SCRIPT_DIR / "docs" / "automation" / "review_status.json"
REVIEW_HISTORY_DIR = SCRIPT_DIR / "docs" / "automation" / "review_history"


class ReviewWorkflow:
    """审核工作流管理器"""

    def __init__(self):
        self.db_file = REVIEW_DB_FILE
        self.history_dir = REVIEW_HISTORY_DIR
        self.reviews = self._load_reviews()

    def _load_reviews(self) -> Dict:
        """加载审核数据"""
        if self.db_file.exists():
            with open(self.db_file, "r", encoding="utf-8") as f:
                return json.load(f)
        return {"items": {}}

    def _save_reviews(self):
        """保存审核数据"""
        self.db_file.parent.mkdir(parents=True, exist_ok=True)
        with open(self.db_file, "w", encoding="utf-8") as f:
            json.dump(self.reviews, f, ensure_ascii=False, indent=2)

    def _get_relative_path(self, file_path: str) -> str:
        """获取相对路径"""
        abs_path = Path(file_path).resolve()
        try:
            return str(abs_path.relative_to(SCRIPT_DIR))
        except ValueError:
            # 如果不在SCRIPT_DIR下，返回绝对路径
            return str(abs_path)

    def _get_file_info(self, file_path: str) -> Dict:
        """获取文件信息"""
        p = Path(file_path)
        if not p.exists():
            raise FileNotFoundError(f"文件不存在: {file_path}")

        # 读取标题（假设是Markdown文件，第一行是标题）
        title = p.stem
        try:
            with open(p, "r", encoding="utf-8") as f:
                first_line = f.readline().strip()
                if first_line.startswith("# "):
                    title = first_line[2:]
        except Exception:
            pass

        return {
            "path": self._get_relative_path(file_path),
            "title": title,
            "modified": datetime.fromtimestamp(p.stat().st_mtime).strftime("%Y-%m-%d %H:%M"),
            "size": p.stat().st_size
        }

    def _add_history(self, file_path: str, action: str, message: str, reviewer: str = "system"):
        """添加审核历史记录"""
        relative_path = self._get_relative_path(file_path)
        self.history_dir.mkdir(parents=True, exist_ok=True)

        history_file = self.history_dir / f"{relative_path.replace('/', '_').replace('.', '_')}.json"

        history = []
        if history_file.exists():
            with open(history_file, "r", encoding="utf-8") as f:
                history = json.load(f)

        history.append({
            "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            "action": action,
            "message": message,
            "reviewer": reviewer
        })

        with open(history_file, "w", encoding="utf-8") as f:
            json.dump(history, f, ensure_ascii=False, indent=2)

    def submit(self, file_path: str, category: str = "default") -> Dict:
        """
        提交文件进行审核

        Args:
            file_path: 文件路径
            category: 内容分类（新手、进阶、物种科普等）

        Returns:
            提交结果
        """
        relative_path = self._get_relative_path(file_path)

        if relative_path in self.reviews["items"]:
            return {"success": False, "message": f"文件已在审核队列中，当前状态: {STATUS_CHINESE.get(self.reviews['items'][relative_path]['status'], '未知')}"}

        file_info = self._get_file_info(file_path)

        self.reviews["items"][relative_path] = {
            "status": ReviewStatus.PENDING.value,
            "category": category,
            "submitted_at": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            "submitted_by": "user",
            "file_info": file_info,
            "check_results": {},
            "review_notes": []
        }

        self._save_reviews()
        self._add_history(file_path, "submit", f"提交审核，分类: {category}")

        return {
            "success": True,
            "message": f"已提交审核: {file_info['title']}",
            "status": STATUS_CHINESE[ReviewStatus.PENDING.value]
        }

    def start_review(self, file_path: str) -> Dict:
        """开始审核"""
        relative_path = self._get_relative_path(file_path)

        if relative_path not in self.reviews["items"]:
            return {"success": False, "message": "文件未提交审核"}

        current_status = self.reviews["items"][relative_path]["status"]

        if current_status not in [ReviewStatus.PENDING.value, ReviewStatus.CHANGES_REQUESTED.value]:
            return {"success": False, "message": f"当前状态不允许开始审核: {STATUS_CHINESE.get(current_status, '未知')}"}

        self.reviews["items"][relative_path]["status"] = ReviewStatus.REVIEWING.value
        self.reviews["items"][relative_path]["review_started_at"] = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        self._save_reviews()
        self._add_history(file_path, "start_review", "开始审核")

        return {"success": True, "message": "开始审核"}

    def request_changes(self, file_path: str, message: str, category: str = "general") -> Dict:
        """要求修改"""
        relative_path = self._get_relative_path(file_path)

        if relative_path not in self.reviews["items"]:
            return {"success": False, "message": "文件未提交审核"}

        self.reviews["items"][relative_path]["status"] = ReviewStatus.CHANGES_REQUESTED.value
        self.reviews["items"][relative_path]["review_notes"].append({
            "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            "type": "changes_requested",
            "category": category,
            "message": message
        })

        self._save_reviews()
        self._add_history(file_path, "request_changes", message)

        return {"success": True, "message": f"已要求修改: {message}"}

    def approve(self, file_path: str, message: str = "") -> Dict:
        """批准发布"""
        relative_path = self._get_relative_path(file_path)

        if relative_path not in self.reviews["items"]:
            return {"success": False, "message": "文件未提交审核"}

        self.reviews["items"][relative_path]["status"] = ReviewStatus.APPROVED.value
        self.reviews["items"][relative_path]["approved_at"] = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        self.reviews["items"][relative_path]["review_notes"].append({
            "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            "type": "approved",
            "message": message or "审核通过"
        })

        self._save_reviews()
        self._add_history(file_path, "approve", message or "审核通过")

        return {"success": True, "message": "已批准发布"}

    def publish(self, file_path: str) -> Dict:
        """标记为已发布"""
        relative_path = self._get_relative_path(file_path)

        if relative_path not in self.reviews["items"]:
            return {"success": False, "message": "文件未提交审核"}

        current_status = self.reviews["items"][relative_path]["status"]

        if current_status != ReviewStatus.APPROVED.value:
            return {"success": False, "message": f"只有已批准的文件才能发布，当前状态: {STATUS_CHINESE.get(current_status, '未知')}"}

        self.reviews["items"][relative_path]["status"] = ReviewStatus.PUBLISHED.value
        self.reviews["items"][relative_path]["published_at"] = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        self._save_reviews()
        self._add_history(file_path, "publish", "已发布")

        return {"success": True, "message": "已标记为已发布"}

    def get_status(self, file_path: str) -> Optional[Dict]:
        """获取文件审核状态"""
        relative_path = self._get_relative_path(file_path)
        return self.reviews["items"].get(relative_path)

    def list_all(self, status_filter: Optional[str] = None, category_filter: Optional[str] = None) -> List[Dict]:
        """列出所有审核项目"""
        items = []
        for path, info in self.reviews["items"].items():
            if status_filter and info["status"] != status_filter:
                continue
            if category_filter and info.get("category") != category_filter:
                continue
            items.append({
                "path": path,
                **info
            })

        # 按提交时间倒序
        items.sort(key=lambda x: x.get("submitted_at", ""), reverse=True)
        return items

    def get_history(self, file_path: str) -> List[Dict]:
        """获取审核历史"""
        relative_path = self._get_relative_path(file_path)
        history_file = self.history_dir / f"{relative_path.replace('/', '_').replace('.', '_')}.json"

        if history_file.exists():
            with open(history_file, "r", encoding="utf-8") as f:
                return json.load(f)
        return []

    def update_check_result(self, file_path: str, check_type: str, result: Dict):
        """更新检查结果"""
        relative_path = self._get_relative_path(file_path)

        if relative_path not in self.reviews["items"]:
            return

        if "check_results" not in self.reviews["items"][relative_path]:
            self.reviews["items"][relative_path]["check_results"] = {}

        self.reviews["items"][relative_path]["check_results"][check_type] = {
            **result,
            "checked_at": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        }

        self._save_reviews()


def format_status(status: str) -> str:
    """格式化状态显示"""
    colors_map = {
        "draft": "gray",
        "pending": "yellow",
        "reviewing": "blue",
        "changes_requested": "red",
        "approved": "green",
        "published": "purple"
    }
    return colored(STATUS_CHINESE.get(status, status), colors_map.get(status, ""))


def main():
    parser = argparse.ArgumentParser(description="内容审核工作流管理")
    subparsers = parser.add_subparsers(dest="command", help="可用命令")

    # 提交审核
    submit_parser = subparsers.add_parser("submit", help="提交文件进行审核")
    submit_parser.add_argument("file", help="文件路径")
    submit_parser.add_argument("--category", "-c", default="default", choices=["default", "newbie", "species", "safety", "price"], help="内容分类")

    # 查看状态
    status_parser = subparsers.add_parser("status", help="查看文件审核状态")
    status_parser.add_argument("file", help="文件路径")

    # 开始审核
    review_parser = subparsers.add_parser("review", help="开始审核")
    review_parser.add_argument("file", help="文件路径")

    # 批准发布
    approve_parser = subparsers.add_parser("approve", help="批准发布")
    approve_parser.add_argument("file", help="文件路径")
    approve_parser.add_argument("--message", "-m", default="", help="批准说明")

    # 要求修改
    reject_parser = subparsers.add_parser("reject", help="要求修改")
    reject_parser.add_argument("file", help="文件路径")
    reject_parser.add_argument("--message", "-m", required=True, help="修改原因")
    reject_parser.add_argument("--category", "-c", default="general", help="问题分类")

    # 发布
    publish_parser = subparsers.add_parser("publish", help="标记为已发布")
    publish_parser.add_argument("file", help="文件路径")

    # 列出所有
    list_parser = subparsers.add_parser("list", help="列出所有审核项目")
    list_parser.add_argument("--status", "-s", choices=["draft", "pending", "reviewing", "changes_requested", "approved", "published"], help="按状态筛选")
    list_parser.add_argument("--category", "-c", help="按分类筛选")

    # 查看历史
    history_parser = subparsers.add_parser("history", help="查看审核历史")
    history_parser.add_argument("file", help="文件路径")

    args = parser.parse_args()

    if not args.command:
        parser.print_help()
        return

    workflow = ReviewWorkflow()

    try:
        if args.command == "submit":
            result = workflow.submit(args.file, args.category)
            if result["success"]:
                print(colored(f"✓ {result['message']}", "green"))
                print(f"  状态: {format_status('pending')}")
            else:
                print(colored(f"✗ {result['message']}", "red"))

        elif args.command == "status":
            status = workflow.get_status(args.file)
            if status:
                print(f"\n文件: {status['file_info']['title']}")
                print(f"路径: {status['path']}")
                print(f"状态: {format_status(status['status'])}")
                print(f"提交时间: {status['submitted_at']}")
                if status.get('approved_at'):
                    print(f"批准时间: {status['approved_at']}")
                if status.get('published_at'):
                    print(f"发布时间: {status['published_at']}")

                # 显示检查结果摘要
                if status.get('check_results'):
                    print(f"\n检查结果:")
                    for check_type, result in status['check_results'].items():
                        check_status = colored("✓", "green") if result.get('passed') else colored("✗", "red")
                        print(f"  {check_status} {check_type}: {result.get('summary', 'N/A')}")

                # 显示审核备注
                notes = status.get('review_notes', [])
                if notes:
                    print(f"\n审核备注 ({len(notes)}条):")
                    for note in notes[-3:]:  # 只显示最近3条
                        print(f"  [{note['timestamp']}] {note['type']}: {note['message'][:50]}...")
            else:
                print(colored("文件未提交审核", "yellow"))

        elif args.command == "review":
            result = workflow.start_review(args.file)
            if result["success"]:
                print(colored(f"✓ {result['message']}", "green"))
            else:
                print(colored(f"✗ {result['message']}", "red"))

        elif args.command == "approve":
            result = workflow.approve(args.file, args.message)
            if result["success"]:
                print(colored(f"✓ {result['message']}", "green"))
            else:
                print(colored(f"✗ {result['message']}", "red"))

        elif args.command == "reject":
            result = workflow.request_changes(args.file, args.message, args.category)
            if result["success"]:
                print(colored(f"✓ {result['message']}", "yellow"))
            else:
                print(colored(f"✗ {result['message']}", "red"))

        elif args.command == "publish":
            result = workflow.publish(args.file)
            if result["success"]:
                print(colored(f"✓ {result['message']}", "purple"))
            else:
                print(colored(f"✗ {result['message']}", "red"))

        elif args.command == "list":
            items = workflow.list_all(args.status, args.category)
            if items:
                print(f"\n共 {len(items)} 个项目:\n")
                print(f"{'状态':<12} {'标题':<40} {'分类':<10} {'提交时间'}")
                print("-" * 80)
                for item in items:
                    title = item['file_info']['title'][:38] + ".." if len(item['file_info']['title']) > 40 else item['file_info']['title']
                    print(f"{format_status(item['status']):<12} {title:<40} {item.get('category', 'default'):<10} {item.get('submitted_at', '')[:10]}")
            else:
                print("没有找到符合条件的项目")

        elif args.command == "history":
            history = workflow.get_history(args.file)
            if history:
                print(f"\n审核历史:\n")
                for record in history:
                    action_color = {
                        "submit": "blue",
                        "start_review": "yellow",
                        "request_changes": "red",
                        "approve": "green",
                        "publish": "purple"
                    }.get(record['action'], "")
                    print(f"[{record['timestamp']}] {colored(record['action'], action_color)}")
                    print(f"  {record['message']}")
                    print()
            else:
                print("暂无审核历史")

    except FileNotFoundError as e:
        print(colored(f"✗ {e}", "red"))
    except Exception as e:
        print(colored(f"✗ 错误: {e}", "red"))
        import traceback
        traceback.print_exc()


if __name__ == "__main__":
    main()
