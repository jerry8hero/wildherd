#!/usr/bin/env python3
"""
审核工作流管理器 - 整合版

功能：
- 一站式审核流程管理
- 自动检查 → 提交审核 → 人工复核 → 发布

用法:
    # 提交审核（自动检查）
    python3 review_manager.py submit <文件路径>

    # 检查内容
    python3 review_manager.py check <文件路径>

    # 审核流程
    python3 review_manager.py workflow <文件路径>

    # 查看状态
    python3 review_manager.py status

    # 帮助
    python3 review_manager.py --help
"""

import os
import sys
import json
import subprocess
from pathlib import Path
from typing import Dict, List, Optional


def run_command(cmd: List[str]) -> tuple:
    """运行命令并返回结果"""
    try:
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            encoding="utf-8"
        )
        return result.returncode == 0, result.stdout, result.stderr
    except Exception as e:
        return False, "", str(e)


def check_content(file_path: str, use_ai: bool = False) -> Dict:
    """检查文件内容"""
    script_dir = Path(__file__).parent
    checker_script = script_dir / "content_checker.py"

    cmd = ["python3", str(checker_script), file_path]
    if use_ai:
        cmd.append("--use-ai")

    success, stdout, stderr = run_command(cmd)

    # 解析输出
    has_errors = "\033[91m❌" in stdout or "存在阻塞性问题" in stdout
    has_warnings = "\033[93m⚠" in stdout or "建议优化" in stdout

    return {
        "success": success,
        "output": stdout,
        "has_errors": has_errors,
        "has_warnings": has_warnings,
        "passed": not has_errors
    }


def submit_for_review(file_path: str, category: str = "default") -> Dict:
    """提交审核"""
    script_dir = Path(__file__).parent
    workflow_script = script_dir / "review_workflow.py"

    cmd = ["python3", str(workflow_script), "submit", file_path, "--category", category]
    success, stdout, stderr = run_command(cmd)

    return {
        "success": success,
        "output": stdout,
        "message": stdout
    }


def get_status(file_path: str = "") -> Dict:
    """获取审核状态"""
    script_dir = Path(__file__).parent
    workflow_script = script_dir / "review_workflow.py"

    if file_path:
        cmd = ["python3", str(workflow_script), "status", file_path]
    else:
        cmd = ["python3", str(workflow_script), "list"]

    success, stdout, stderr = run_command(cmd)

    return {
        "success": success,
        "output": stdout
    }


def full_workflow(file_path: str, use_ai: bool = False, auto_approve: bool = False) -> Dict:
    """
    完整审核工作流

    流程：
    1. 内容检查
    2. 提交审核
    3. 查看结果
    """

    print("\n" + "="*60)
    print("📋 审核工作流")
    print("="*60)

    file_path_obj = Path(file_path)
    if not file_path_obj.exists():
        return {"success": False, "message": f"文件不存在: {file_path}"}

    print(f"\n📄 文件: {file_path_obj.name}")

    # 步骤1: 内容检查
    print("\n" + "-"*40)
    print("🔍 步骤1: 内容检查")
    print("-"*40)

    check_result = check_content(file_path, use_ai)

    if check_result["has_errors"]:
        print("\n❌ 内容检查未通过，存在阻塞性问题")
        print("请修复问题后重新提交")

        if "output" in check_result:
            # 只显示关键信息
            lines = check_result["output"].split("\n")
            for line in lines:
                if "错误" in line or "⚠" in line or "✓" in line or "✗" in line or "❌" in line or "✅" in line or "⚠️" in line:
                    print(line)

        return {"success": False, "message": "内容检查未通过"}

    print("\n✅ 内容检查通过")

    # 步骤2: 提交审核
    print("\n" + "-"*40)
    print("📝 步骤2: 提交审核")
    print("-"*40)

    # 推断分类
    category = "default"
    content_lower = file_path.lower()
    if any(kw in content_lower for kw in ["新手", "入门", "newbie"]):
        category = "newbie"
    elif any(kw in content_lower for kw in ["安全", "咬伤", "警示"]):
        category = "safety"
    elif any(kw in content_lower for kw in ["价格", "购买", "经济"]):
        category = "price"
    elif any(kw in content_lower for kw in ["品种", "科普", "物种"]):
        category = "species"

    submit_result = submit_for_review(file_path, category)

    if submit_result["success"]:
        print("✅ 已提交审核")

        # 显示提交结果
        for line in submit_result["output"].split("\n"):
            if "✓" in line or "状态" in line:
                print(line)
    else:
        print(f"⚠️ {submit_result.get('message', '提交失败')}")

    # 步骤3: 显示审核状态
    print("\n" + "-"*40)
    print("📊 步骤3: 审核状态")
    print("-"*40)

    status_result = get_status(file_path)

    if status_result["success"]:
        # 只显示关键状态信息
        output_lines = status_result["output"].split("\n")
        for line in output_lines[:15]:  # 只显示前15行
            print(line)

    # 完成
    print("\n" + "="*60)
    print("📌 下一步操作:")
    print("="*60)
    print("  1. 人工复核内容（推荐）")
    print("  2. 批准发布: python3 review_workflow.py approve <文件>")
    print("  3. 发布: python3 review_workflow.py publish <文件>")
    print("  4. 查看所有: python3 review_workflow.py list")
    print("="*60)

    return {
        "success": True,
        "check_passed": True,
        "submitted": True,
        "message": "审核流程完成"
    }


def main():
    import argparse

    parser = argparse.ArgumentParser(
        description="审核工作流管理器",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
示例:
  # 提交审核（自动检查）
  python3 review_manager.py submit docs/video-scripts/鳄龟/01-新手入门.md

  # 仅检查内容
  python3 review_manager.py check docs/video-scripts/鳄龟/01-新手入门.md

  # 完整工作流（带AI检查）
  python3 review_manager.py workflow docs/video-scripts/鳄龟/01-新手入门.md --use-ai

  # 查看所有待审核
  python3 review_manager.py status

工作流状态:
  草稿(draft) → 待审核(pending) → 审核中(reviewing) → 需要修改(changes_requested)
                                                                    ↓
  已发布(published) ← ← ← ← ← ← ← ← 已批准(approved) ← ← ← ← ← ← ← ←
        """
    )

    subparsers = parser.add_subparsers(dest="command", help="可用命令")

    # 提交审核
    submit_parser = subparsers.add_parser("submit", help="提交文件进行审核")
    submit_parser.add_argument("file", help="文件路径")
    submit_parser.add_argument("--category", "-c", default="default", help="分类")
    submit_parser.add_argument("--no-check", action="store_true", help="跳过内容检查")

    # 检查内容
    check_parser = subparsers.add_parser("check", help="仅检查内容")
    check_parser.add_argument("file", help="文件路径")
    check_parser.add_argument("--use-ai", action="store_true", help="使用AI检查")

    # 完整工作流
    workflow_parser = subparsers.add_parser("workflow", help="完整审核工作流")
    workflow_parser.add_argument("file", help="文件路径")
    workflow_parser.add_argument("--use-ai", action="store_true", help="使用AI检查")
    workflow_parser.add_argument("--auto-approve", action="store_true", help="自动批准（危险）")

    # 状态查看
    status_parser = subparsers.add_parser("status", help="查看审核状态")
    status_parser.add_argument("file", nargs="?", help="文件路径（可选）")

    args = parser.parse_args()

    if not args.command:
        parser.print_help()
        return

    try:
        if args.command == "submit":
            if args.no_check:
                result = submit_for_review(args.file, args.category)
                print(result["output"])
            else:
                # 先检查再提交
                print("🔍 先进行内容检查...")
                check_result = check_content(args.file, False)
                if check_result["has_errors"]:
                    print("\n❌ 内容检查未通过，请修复问题后再提交")
                    sys.exit(1)
                print("✅ 检查通过，正在提交...")
                result = submit_for_review(args.file, args.category)
                print(result["output"])

        elif args.command == "check":
            result = check_content(args.file, args.use_ai)
            print(result["output"])

        elif args.command == "workflow":
            result = full_workflow(args.file, args.use_ai, args.auto_approve)
            if not result["success"]:
                sys.exit(1)

        elif args.command == "status":
            result = get_status(args.file)
            print(result["output"])

    except KeyboardInterrupt:
        print("\n\n操作已取消")
        sys.exit(0)
    except Exception as e:
        print(f"\n错误: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    main()
