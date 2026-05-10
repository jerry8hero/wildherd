#!/usr/bin/env python3
"""
自动化文案Review脚本
对视频文案进行3轮迭代优化
"""

import json
import os
import re
from pathlib import Path

# MiniMax API配置
API_KEY = "sk-cp-UZAUY_uogMBUAHvjpnPayc1ClIOnCiWPE8vokHl2tGm_Rv55sp-SpHfZGgHgk62jG93k_dYSztm0BL6XvH87DS5Ju-wnNOtjAqVcdueLdQK0w60aQrcK0VE"
API_ENDPOINT = "https://api.minimaxi.com/anthropic/v1/messages"

def call_minimax_review(content: str, round_num: int) -> str:
    """调用MiniMax API进行Review"""
    import urllib.request

    prompt = f"""你是一个专业的B站视频文案编辑。请对以下文案进行第{round_num}轮Review和优化。

要求：
1. 保持B站风格：年轻、活泼、有梗、接地气
2. 优化内容包括：开头吸引力、信息准确性、叙事流畅性、结尾互动性
3. 直接输出优化后的完整文案，不要解释

review 并修改以下文案，直接输出完整修改版：

{content}"""

    data = {
        "model": "MiniMax-M2.7",
        "max_tokens": 8000,
        "messages": [
            {
                "role": "user",
                "content": prompt
            }
        ]
    }

    req = urllib.request.Request(
        API_ENDPOINT,
        data=json.dumps(data).encode('utf-8'),
        headers={
            'Content-Type': 'application/json',
            'x-api-key': API_KEY,
            'anthropic-version': '2023-06-01'
        },
        method='POST'
    )

    with urllib.request.urlopen(req, timeout=120) as response:
        result = json.loads(response.read().decode('utf-8'))

    if result.get('type') == 'error':
        raise Exception(f"API Error: {result.get('error', {}).get('message', 'Unknown error')}")

    # 从结果中提取文本内容
    content_list = result.get('content', [])
    for item in content_list:
        if item.get('type') == 'text':
            return item.get('text', '')

    raise Exception("No text response from API")

def extract_main_content(content: str) -> str:
    """提取视频正文文案部分（#之后，B站发布内容之前）"""
    # 查找 --- 分隔符，取第一部分
    parts = content.split('---')
    if parts:
        return parts[0].strip()
    return content

def three_round_review(file_path: str) -> str:
    """对单个文件进行3轮Review"""
    print(f"  处理文件: {file_path}")

    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # 提取正文部分（不含B站发布内容）
    main_content = extract_main_content(content)
    print(f"    原文案长度: {len(main_content)} 字符")

    # 第一轮Review
    print(f"    第1轮Review...")
    reviewed_1 = call_minimax_review(main_content, 1)

    # 第二轮Review
    print(f"    第2轮Review...")
    reviewed_2 = call_minimax_review(reviewed_1, 2)

    # 第三轮Review
    print(f"    第3轮Review...")
    reviewed_3 = call_minimax_review(reviewed_2, 3)

    print(f"    优化后长度: {len(reviewed_3)} 字符")

    # 重新组装完整文案
    parts = content.split('---')
    if len(parts) > 1:
        return reviewed_3 + '\n\n---\n\n' + '---'.join(parts[1:])
    return reviewed_3

def process_directory(base_dir: str, start_num: int = 2, end_num: int = 101):
    """处理目录下的所有视频文案文件"""
    base_path = Path(base_dir)

    for num in range(start_num, end_num + 1):
        num_str = f"{num:03d}"
        # 查找对应的目录
        matching_dirs = list(base_path.glob(f"{num_str}-*"))

        if not matching_dirs:
            print(f"跳过 {num_str}: 未找到对应目录")
            continue

        dir_path = matching_dirs[0]
        if not dir_path.is_dir():
            continue

        # 查找markdown文件
        md_files = list(dir_path.glob("*.md"))
        if not md_files:
            print(f"跳过 {num_str}: 目录中无md文件")
            continue

        file_path = md_files[0]
        try:
            optimized = three_round_review(str(file_path))
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(optimized)
            print(f"    ✓ 完成: {file_path.name}")
        except Exception as e:
            print(f"    ✗ 错误: {e}")

if __name__ == "__main__":
    import sys

    base_dir = "/Users/mac/Desktop/workspace/github/private/wildherd/docs/video/scripts/冷到你唔信/第一册-哺乳动物"

    if len(sys.argv) > 1:
        start = int(sys.argv[1])
        end = int(sys.argv[2]) if len(sys.argv) > 2 else start
    else:
        start = 2
        end = 101

    print(f"开始处理: {start:03d} - {end:03d}")
    print("=" * 50)

    process_directory(base_dir, start, end)

    print("=" * 50)
    print("处理完成!")