#!/usr/bin/env python3
"""
MiniMax API 客户端 - 用于AI辅助创作

功能：
- 标题生成
- 标签推荐
- 简介撰写
- 脚本润色
- 章节划分

环境变量配置：
    export MINIMAX_API_KEY="your_api_key"
    export MINIMAX_GROUP_ID="your_group_id"

安装依赖：
    pip install requests

使用方法：
    python3 minimax_client.py --prompt "生成10个B站视频标题" --topic "鳄龟饲养"
"""

import os
import sys
import json
import argparse
from pathlib import Path
from typing import Optional, List, Dict, Any

try:
    import requests
except ImportError:
    print("请先安装 requests: pip install requests")
    sys.exit(1)


# 配置
# MiniMax Coding Plan 使用国内版 API
API_URL = "https://api.minimaxi.com/v1/text/chatcompletion_pro"
DEFAULT_MODEL = "abab6.5s-chat"


def load_prompt_template(template_name: str, **kwargs) -> str:
    """加载提示词模板"""
    prompts_dir = Path(__file__).parent.parent / "prompts"
    template_file = prompts_dir / f"{template_name}.txt"

    if not template_file.exists():
        raise FileNotFoundError(f"模板文件不存在: {template_file}")

    with open(template_file, "r", encoding="utf-8") as f:
        template = f.read()

    # 替换模板变量
    for key, value in kwargs.items():
        template = template.replace(f"{{{key}}}", str(value))

    return template


def call_minimax_api(
    prompt: str,
    api_key: Optional[str] = None,
    group_id: Optional[str] = None,
    model: str = DEFAULT_MODEL,
    temperature: float = 0.7,
    max_tokens: int = 2048
) -> str:
    """
    调用 MiniMax API

    Args:
        prompt: 提示词
        api_key: API密钥 (默认从环境变量读取)
        group_id: 组ID (默认从环境变量读取)
        model: 模型名称
        temperature: 温度参数 (0-1，越高越有创意)
        max_tokens: 最大生成token数

    Returns:
        API返回的文本内容
    """
    api_key = api_key or os.environ.get("MINIMAX_API_KEY")
    group_id = group_id or os.environ.get("MINIMAX_GROUP_ID")

    if not api_key:
        raise ValueError(
            "请设置环境变量 MINIMAX_API_KEY\n"
            "或者在调用时传入 api_key 参数"
        )

    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {api_key}"
    }

    payload = {
        "model": model,
        "tokens_to_generate": max_tokens,
        "temperature": temperature,
        "top_p": 0.9,
        "stream": False,
        "reply_constraints": {
            "sender_type": "BOT",
            "sender_name": "MM智能助理"
        },
        "bot_setting": [
            {
                "bot_name": "MM智能助理",
                "content": "一个有用的助手"
            }
        ],
        "messages": [
            {
                "sender_type": "USER",
                "sender_name": "用户",
                "text": prompt
            }
        ]
    }

    # Coding Plan 的 API 可能不需要 GroupId 参数
    if group_id:
        url = f"{API_URL}?GroupId={group_id}"
    else:
        url = API_URL

    try:
        response = requests.post(url, headers=headers, json=payload, timeout=60)
        response.raise_for_status()

        result = response.json()

        # 解析返回内容
        if "choices" in result and len(result["choices"]) > 0:
            return result["choices"][0].get("text", "")

        # MiniMax API 响应格式
        if "messages" in result and len(result["messages"]) > 0:
            return result["messages"][-1].get("text", "")

        return str(result)

    except requests.exceptions.Timeout:
        raise TimeoutError("API请求超时，请稍后重试")
    except requests.exceptions.RequestException as e:
        raise ConnectionError(f"API请求失败: {e}")


def generate_titles(topic: str, keywords: str = "", count: int = 10) -> List[str]:
    """生成视频标题"""
    template = load_prompt_template(
        "title_template",
        主题关键词=keywords or topic,
        输入视频主题=topic
    )

    result = call_minimax_api(template)
    titles = [line.strip() for line in result.strip().split("\n") if line.strip()]

    # 返回指定数量
    return titles[:count]


def generate_tags(content_summary: str, topic: str) -> List[str]:
    """生成标签"""
    template = load_prompt_template(
        "tag_template",
        输入内容摘要=content_summary,
        输入主题=topic
    )

    result = call_minimax_api(template)

    # 解析逗号分隔的标签
    tags = [tag.strip() for tag in result.replace("\n", ",").split(",") if tag.strip()]

    return tags[:20]


def generate_description(title: str, topic: str, key_points: str) -> str:
    """生成视频简介"""
    template = load_prompt_template(
        "description_template",
        标题=title,
        主题=topic,
        要点1=key_points.split(",")[0] if "," in key_points else key_points,
        要点2=key_points.split(",")[1] if "," in key_points and len(key_points.split(",")) > 1 else "",
        要点3=key_points.split(",")[2] if "," in key_points and len(key_points.split(",")) > 2 else ""
    )

    return call_minimax_api(template)


def polish_script(script: str) -> str:
    """润色脚本"""
    template = load_prompt_template(
        "script_polish_template",
        输入原始脚本=script
    )

    return call_minimax_api(template, temperature=0.8)


def generate_chapters(topic: str, duration: str, script: str) -> str:
    """生成章节时间轴"""
    template = load_prompt_template(
        "chapter_template",
        主题=topic,
        时长=duration,
        输入脚本内容=script
    )

    return call_minimax_api(template, max_tokens=1024)


def generate_comment(title: str, topic: str) -> str:
    """生成置顶评论"""
    template = load_prompt_template(
        "comment_template",
        标题=title,
        主题=topic
    )

    return call_minimax_api(template, max_tokens=256)


def main():
    parser = argparse.ArgumentParser(description="MiniMax API 客户端 - AI辅助创作工具")
    subparsers = parser.add_subparsers(dest="command", help="可用命令")

    # 标题生成
    titles_parser = subparsers.add_parser("titles", help="生成视频标题")
    titles_parser.add_argument("--topic", "-t", required=True, help="视频主题")
    titles_parser.add_argument("--keywords", "-k", default="", help="关键词")
    titles_parser.add_argument("--count", "-n", type=int, default=10, help="生成数量")

    # 标签生成
    tags_parser = subparsers.add_parser("tags", help="生成标签")
    tags_parser.add_argument("--summary", "-s", required=True, help="内容摘要")
    tags_parser.add_argument("--topic", "-t", required=True, help="视频主题")

    # 简介生成
    desc_parser = subparsers.add_parser("description", help="生成视频简介")
    desc_parser.add_argument("--title", required=True, help="视频标题")
    desc_parser.add_argument("--topic", "-t", required=True, help="视频主题")
    desc_parser.add_argument("--points", "-p", required=True, help="关键要点(逗号分隔)")

    # 脚本润色
    polish_parser = subparsers.add_parser("polish", help="润色脚本")
    polish_parser.add_argument("--file", "-f", required=True, help="脚本文件路径")

    # 章节生成
    chapter_parser = subparsers.add_parser("chapters", help="生成章节时间轴")
    chapter_parser.add_argument("--topic", "-t", required=True, help="视频主题")
    chapter_parser.add_argument("--duration", "-d", default="10", help="视频时长(分钟)")
    chapter_parser.add_argument("--script", required=True, help="脚本内容或文件路径")

    # 置顶评论
    comment_parser = subparsers.add_parser("comment", help="生成置顶评论")
    comment_parser.add_argument("--title", required=True, help="视频标题")
    comment_parser.add_argument("--topic", "-t", required=True, help="视频主题")

    # 配置检查
    config_parser = subparsers.add_parser("config", help="检查API配置")

    args = parser.parse_args()

    if not args.command:
        parser.print_help()
        return

    # 检查配置
    api_key = os.environ.get("MINIMAX_API_KEY")
    group_id = os.environ.get("MINIMAX_GROUP_ID")

    if args.command == "config":
        print("MiniMax API 配置检查")
        print("=" * 50)
        if api_key:
            print(f"API Key: {'*' * 20}{api_key[-4:]}")
        else:
            print("API Key: 未设置")
        if group_id:
            print(f"Group ID: {group_id}")
        else:
            print("Group ID: 未设置")
        print("=" * 50)
        if not api_key or not group_id:
            print("\n请设置环境变量:")
            print('  export MINIMAX_API_KEY="your_api_key"')
            print('  export MINIMAX_GROUP_ID="your_group_id"')
        return

    # 检查API配置
    if not api_key or not group_id:
        print("错误: 请先配置 MINIMAX_API_KEY 和 MINIMAX_GROUP_ID")
        print("运行: python3 minimax_client.py config")
        sys.exit(1)

    # 执行命令
    try:
        if args.command == "titles":
            print(f"\n正在为主题「{args.topic}」生成标题...\n")
            titles = generate_titles(args.topic, args.keywords, args.count)
            for i, title in enumerate(titles, 1):
                print(f"{i}. {title}")

        elif args.command == "tags":
            print(f"\n正在生成标签...\n")
            tags = generate_tags(args.summary, args.topic)
            print("生成的标签:")
            print(", ".join(tags))

        elif args.command == "description":
            print(f"\n正在生成视频简介...\n")
            desc = generate_description(args.title, args.topic, args.points)
            print(desc)

        elif args.command == "polish":
            script_path = Path(args.file)
            if not script_path.exists():
                print(f"错误: 文件不存在 {args.file}")
                sys.exit(1)

            with open(script_path, "r", encoding="utf-8") as f:
                script = f.read()

            print(f"\n正在润色脚本「{script_path.name}」...\n")
            polished = polish_script(script)
            print(polished)

        elif args.command == "chapters":
            # 检查是否是文件路径
            script_content = args.script
            if Path(args.script).exists():
                with open(args.script, "r", encoding="utf-8") as f:
                    script_content = f.read()

            print(f"\n正在生成章节时间轴...\n")
            chapters = generate_chapters(args.topic, args.duration, script_content)
            print(chapters)

        elif args.command == "comment":
            print(f"\n正在生成置顶评论...\n")
            comment = generate_comment(args.title, args.topic)
            print(comment)

    except Exception as e:
        print(f"错误: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
