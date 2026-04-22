#!/usr/bin/env python3
"""
MiniMax 文案 Review 自动化脚本

功能：
- 读取 markdown 文案文件
- 调用 MiniMax API 进行 review
- 根据 review 建议自动修改文案
- 支持多轮迭代

用法:
    # 单次 review（不修改）
    python3 minimax_reviewer.py review <文件路径>

    # review + 自动修改
    python3 minimax_reviewer.py review <文件路径> --apply

    # 多轮迭代 review + 修改（默认3轮）
    python3 minimax_reviewer.py iterate <文件路径>

    # 自定义迭代轮数
    python3 minimax_reviewer.py iterate <文件路径> --rounds 5

    # 设置 reviewer 类型（B站/通用）
    python3 minimax_reviewer.py iterate <文件路径> --reviewer bilibili
"""

import os
import sys
import json
import argparse
import re
from pathlib import Path
from typing import Dict, Optional, Tuple
from datetime import datetime

try:
    import requests
except ImportError:
    print("请先安装 requests: pip install requests")
    sys.exit(1)


# MiniMax API 配置
# 中国版端点（API Key 格式 sk-cp- 适用）
MINIMAX_API_URL = "https://api.minimaxi.com/v1/text/chatcompletion_v2"
MINIMAX_MODEL = "MiniMax-M2.5"  # Coding Plan 支持的旗舰模型

# 配色方案
COLORS = {
    "red": "\033[91m",
    "green": "\033[92m",
    "yellow": "\033[93m",
    "blue": "\033[94m",
    "purple": "\033[95m",
    "cyan": "\033[96m",
    "end": "\033[0m",
    "bold": "\033[1m"
}


def colored(text: str, color: str) -> str:
    """给文本添加颜色"""
    return f"{COLORS.get(color, '')}{text}{COLORS['end']}"


def get_api_key() -> str:
    """获取 MiniMax API Key"""
    # 优先从环境变量获取
    api_key = os.environ.get("MINIMAX_API_KEY")
    if api_key:
        return api_key

    # 从 ~/.config/minimax/config.json 获取
    config_path = Path.home() / ".config" / "minimax" / "config.json"
    if config_path.exists():
        try:
            with open(config_path, "r") as f:
                config = json.load(f)
                for profile in config.get("profile", []):
                    if profile.get("apikey"):
                        return profile["apikey"]
        except Exception:
            pass

    raise ValueError("未找到 MiniMax API Key，请设置 MINIMAX_API_KEY 环境变量")


def call_minimax(messages: list, temperature: float = 0.7, max_tokens: int = 4096) -> str:
    """调用 MiniMax API"""
    api_key = get_api_key()
    group_id = os.environ.get("MINIMAX_GROUP_ID", "")

    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {api_key}"
    }

    data = {
        "model": MINIMAX_MODEL,
        "messages": messages,
        "temperature": temperature,
        "max_tokens": max_tokens
    }

    if group_id:
        data["group_id"] = group_id

    response = requests.post(MINIMAX_API_URL, headers=headers, json=data, timeout=120)

    if response.status_code != 200:
        raise Exception(f"API 调用失败: {response.status_code} - {response.text}")

    result = response.json()
    return result["choices"][0]["message"]["content"]


def read_markdown(file_path: str) -> Tuple[str, str]:
    """
    读取 markdown 文件
    返回: (内容, 原始内容)
    """
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()
    return content, content


def save_markdown(file_path: str, content: str):
    """保存 markdown 文件"""
    # 先备份
    backup_path = f"{file_path}.bak"
    with open(backup_path, "w", encoding="utf-8") as f:
        with open(file_path, "r", encoding="utf-8") as orig:
            f.write(orig.read())

    # 保存新内容
    with open(file_path, "w", encoding="utf-8") as f:
        f.write(content)

    print(colored(f"✓ 文件已保存 (备份: {backup_path})", "green"))


def build_review_prompt(content: str, reviewer_type: str = "bilibili") -> str:
    """构建 review prompt"""
    if reviewer_type == "bilibili":
        return f"""你是一个专业的B站视频文案策划师。请帮我 review 以下视频文案，从以下几个角度给出详细的修改建议：

1. **内容结构**：逻辑是否清晰，层次是否分明
2. **节奏把控**：开头是否能吸引观众，高潮部分是否有冲击力，结尾是否有力
3. **话术表达**：语言是否口语化、生动，是否有重复啰嗦的地方
4. **B站特性**：是否符合B站观众的喜好（互动感、梗点、人设感）
5. **观众留存**：哪些地方可能会让观众流失
6. **知识准确性**：是否有错误或可能误导观众的内容
7. **亮点与不足**：分别列出

文案如下：

---

{content}

---

请给出详细的修改建议，并尽量给出具体的修改示例。"""
    else:
        return f"""你是一个专业的视频文案策划师。请帮我 review 以下文案，从以下几个角度给出详细的修改建议：

1. **内容结构**：逻辑是否清晰，层次是否分明
2. **节奏把控**：开头是否能吸引观众，高潮部分是否有冲击力，结尾是否有力
3. **话术表达**：语言是否口语化、生动，是否有重复啰嗦的地方
4. **观众留存**：哪些地方可能会让观众流失
5. **知识准确性**：是否有错误或可能误导观众的内容
6. **亮点与不足**：分别列出

文案如下：

---

{content}

---

请给出详细的修改建议，并尽量给出具体的修改示例。"""


def build_modify_prompt(content: str, review_feedback: str, reviewer_type: str = "bilibili") -> str:
    """构建修改 prompt"""
    return f"""你是一个专业的B站视频文案策划师。我需要你根据以下 review 建议，帮我修改文案。

## 原始文案

---

{content}

---

## Review 建议

---

{review_feedback}

---

## 要求

1. 根据 review 建议修改文案
2. 保持文案风格活泼、口语化，符合B站风格
3. 保留原文案的核心内容
4. 直接输出修改后的完整文案，不要解释修改了什么

请直接输出修改后的完整文案："""


def parse_review_feedback(feedback: str) -> Dict:
    """解析 review 反馈，提取关键信息"""
    result = {
        "score": None,
        "pros": [],
        "cons": [],
        "suggestions": []
    }

    # 尝试提取评分
    score_match = re.search(r"评分[：:]\s*(\d+)/(\d+)", feedback)
    if score_match:
        result["score"] = f"{score_match.group(1)}/{score_match.group(2)}"

    # 提取亮点
    in_pros = False
    for line in feedback.split("\n"):
        line = line.strip()
        if "亮点" in line or "优点" in line or "值得" in line:
            in_pros = True
            continue
        if "不足" in line or "缺点" in line or "问题" in line:
            in_pros = False
            continue
        if line.startswith("-") or line.startswith("•") or line.startswith("*"):
            if in_pros:
                result["pros"].append(line.lstrip("-•* ").strip())
            else:
                result["cons"].append(line.lstrip("-•* ").strip())

    return result


def review_script(file_path: str, reviewer_type: str = "bilibili", apply: bool = False) -> bool:
    """
    Review 文案

    Args:
        file_path: 文件路径
        reviewer_type: reviewer 类型 (bilibili/general)
        apply: 是否自动应用修改

    Returns:
        是否成功
    """
    print(colored("\n" + "=" * 60, "cyan"))
    print(colored("🔍 MiniMax 文案 Review", "bold"))
    print(colored("=" * 60, "cyan"))

    # 读取文件
    print(f"\n📄 读取文件: {file_path}")
    content, _ = read_markdown(file_path)

    if not content.strip():
        print(colored("❌ 文件内容为空", "red"))
        return False

    print(colored(f"✓ 文件读取成功 ({(len(content))} 字符)", "green"))

    # 调用 MiniMax review
    print(colored("\n⏳ 正在调用 MiniMax API 进行 review...", "yellow"))
    print(colored("   (这可能需要几十秒，请耐心等待...)\n", "yellow"))

    try:
        prompt = build_review_prompt(content, reviewer_type)
        messages = [{"role": "user", "content": prompt}]
        feedback = call_minimax(messages)

        print(colored("✓ Review 完成！\n", "green"))

        # 显示 review 结果
        print(colored("-" * 60, "cyan"))
        print(colored("📋 Review 结果", "bold"))
        print(colored("-" * 60, "cyan"))
        print()

        # 打印 feedback，每行加上颜色
        for line in feedback.split("\n"):
            line = line.strip()
            if not line:
                print()
                continue
            if "亮点" in line or "优点" in line:
                print(colored(line, "green"))
            elif "不足" in line or "缺点" in line:
                print(colored(line, "red"))
            elif "建议" in line or "修改" in line:
                print(colored(line, "yellow"))
            elif line.startswith("**") and "**" in line[2:]:
                # 标题行
                print(colored(line, "bold"))
            else:
                print(line)

        print()

        # 如果需要应用修改
        if apply:
            print(colored("-" * 60, "cyan"))
            print(colored("✏️  应用修改中...", "yellow"))

            modify_prompt = build_modify_prompt(content, feedback, reviewer_type)
            modify_messages = [{"role": "user", "content": modify_prompt}]
            modified_content = call_minimax(modify_messages)

            # 保存修改
            save_markdown(file_path, modified_content)

            print(colored("✓ 修改完成！\n", "green"))

        return True

    except Exception as e:
        print(colored(f"\n❌ Error: {e}", "red"))
        return False


def iterate_review(file_path: str, rounds: int = 3, reviewer_type: str = "bilibili") -> bool:
    """
    多轮迭代 review

    Args:
        file_path: 文件路径
        rounds: 迭代轮数
        reviewer_type: reviewer 类型

    Returns:
        是否成功
    """
    print(colored("\n" + "=" * 60, "cyan"))
    print(colored("🔄 MiniMax 文案迭代 Review", "bold"))
    print(colored("=" * 60, "cyan"))
    print(colored(f"   文件: {file_path}", "yellow"))
    print(colored(f"   轮数: {rounds}", "yellow"))
    print(colored(f"   Reviewer: {reviewer_type}", "yellow"))
    print()

    # 读取原始文件
    original_content, _ = read_markdown(file_path)
    current_content = original_content

    # 保存 review 历史
    review_history = []
    backup_content = current_content

    for i in range(1, rounds + 1):
        print(colored(f"\n{'=' * 60}", "cyan"))
        print(colored(f"📝 第 {i}/{rounds} 轮 Review", "bold"))
        print(colored(f"{'=' * 60}", "cyan"))

        try:
            # 1. Review 当前版本
            print(colored("\n⏳ 调用 MiniMax API 进行 review...", "yellow"))

            prompt = build_review_prompt(current_content, reviewer_type)
            feedback = call_minimax([{"role": "user", "content": prompt}])

            print(colored("✓ Review 完成！\n", "green"))

            # 解析反馈
            parsed = parse_review_feedback(feedback)

            if parsed["score"]:
                print(colored(f"   评分: {parsed['score']}", "yellow"))

            if parsed["pros"]:
                print(colored(f"   亮点: {len(parsed['pros'])} 条", "green"))

            if parsed["cons"]:
                print(colored(f"   不足: {len(parsed['cons'])} 条", "red"))

            # 保存 review 历史
            review_history.append({
                "round": i,
                "feedback": feedback,
                "parsed": parsed
            })

            # 2. 如果不是最后一轮，应用修改
            if i < rounds:
                print(colored("\n⏳ 根据 review 建议修改文案...", "yellow"))

                modify_prompt = build_modify_prompt(current_content, feedback, reviewer_type)
                current_content = call_minimax([{"role": "user", "content": modify_prompt}])

                # 保存修改后的内容
                save_markdown(file_path, current_content)
                print(colored("✓ 修改已保存", "green"))

                # 对比变化
                old_lines = len(backup_content.split("\n"))
                new_lines = len(current_content.split("\n"))
                print(colored(f"   文本行数: {old_lines} → {new_lines}", "yellow"))
                backup_content = current_content

        except Exception as e:
            print(colored(f"\n❌ 第 {i} 轮出错: {e}", "red"))
            # 恢复到最后一次成功的内容
            if backup_content != original_content:
                print(colored("   恢复到最后一次保存的版本...", "yellow"))
                with open(file_path, "w", encoding="utf-8") as f:
                    f.write(backup_content)
            continue

    # 最终 review（最后一轮只 review 不修改）
    print(colored(f"\n{'=' * 60}", "cyan"))
    print(colored(f"📋 第 {rounds} 轮 Review 结果", "bold"))
    print(colored(f"{'=' * 60}", "cyan"))
    print(feedback[:2000])  # 显示最后 feedback 的前2000字

    print(colored("\n" + "=" * 60, "cyan"))
    print(colored("✅ 迭代 Review 完成！", "green"))
    print(colored("=" * 60, "cyan"))
    print()
    print(colored(f"📄 修改后的文件: {file_path}", "yellow"))
    print(colored(f"📜 Review 历史: {len(review_history)} 轮", "yellow"))
    print()
    print(colored("💡 建议：仔细阅读最后一轮 review 结果，确认修改是否符合预期", "cyan"))

    return True


def main():
    parser = argparse.ArgumentParser(
        description="MiniMax 文案 Review 自动化工具",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
示例:
  # 单次 review（只看不改）
  python3 minimax_reviewer.py review docs/video-scripts/鳄龟/04-鳄龟喂食指南.md

  # review + 自动修改
  python3 minimax_reviewer.py review docs/video-scripts/鳄龟/04-鳄龟喂食指南.md --apply

  # 多轮迭代 review + 修改（默认3轮）
  python3 minimax_reviewer.py iterate docs/video-scripts/鳄龟/04-鳄龟喂食指南.md

  # 自定义迭代轮数
  python3 minimax_reviewer.py iterate docs/video-scripts/鳄龟/04-鳄龟喂食指南.md --rounds 5

  # 使用通用 reviewer（非B站）
  python3 minimax_reviewer.py review docs/video-scripts/鳄龟/04-鳄龟喂食指南.md --reviewer general

环境变量:
  MINIMAX_API_KEY - MiniMax API Key（必需）
  MINIMAX_GROUP_ID - MiniMax Group ID（可选）
"""
    )

    subparsers = parser.add_subparsers(dest="command", help="可用命令")

    # review 命令
    review_parser = subparsers.add_parser("review", help="Review 文案（可选是否应用修改）")
    review_parser.add_argument("file", help="文件路径")
    review_parser.add_argument("--apply", "-a", action="store_true", help="应用修改")
    review_parser.add_argument("--reviewer", "-r", default="bilibili",
                              choices=["bilibili", "general"],
                              help="Reviewer 类型 (默认: bilibili)")

    # iterate 命令
    iterate_parser = subparsers.add_parser("iterate", help="多轮迭代 Review")
    iterate_parser.add_argument("file", help="文件路径")
    iterate_parser.add_argument("--rounds", "-n", type=int, default=3,
                               help="迭代轮数 (默认: 3)")
    iterate_parser.add_argument("--reviewer", "-r", default="bilibili",
                               choices=["bilibili", "general"],
                               help="Reviewer 类型 (默认: bilibili)")

    args = parser.parse_args()

    if not args.command:
        parser.print_help()
        return

    # 检查文件是否存在
    if not Path(args.file).exists():
        print(colored(f"❌ 文件不存在: {args.file}", "red"))
        sys.exit(1)

    try:
        if args.command == "review":
            success = review_script(args.file, args.reviewer, args.apply)
            sys.exit(0 if success else 1)

        elif args.command == "iterate":
            success = iterate_review(args.file, args.rounds, args.reviewer)
            sys.exit(0 if success else 1)

    except KeyboardInterrupt:
        print(colored("\n\n⚠️ 操作已取消", "yellow"))
        sys.exit(130)
    except Exception as e:
        print(colored(f"\n❌ 错误: {e}", "red"))
        import traceback
        traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    main()