#!/usr/bin/env python3
"""修复后：从第 1 轮提取优化版，串行重跑第 2、3 轮"""

import json
import re
import sys
import time
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))

from review_core import ReviewConfig, MiniMaxClient

TARGET = Path("/home/bigrice/workspace/github/private/wildherd/docs/video/scripts/龟类对比/04-不同品种龟的价格大对比.md")
PROMPTS_DIR = Path("/home/bigrice/workspace/github/private/wildherd/tools/prompts")
LOG = Path("/home/bigrice/workspace/github/private/wildherd/tools/review/state/single_review_04.json")


def load_prompt(name: str) -> str:
    with open(PROMPTS_DIR / name, 'r', encoding='utf-8') as f:
        text = f.read()
    return '\n'.join(text.strip().split('\n')[:-1])


def extract_optimized(output: str) -> str:
    """提取优化后的完整文案 - 多种匹配策略"""
    # 策略 1: 找 # 优化后... 标记后的第一个 # 标题行
    # 因为模型先输出评审，再输出 "# 优化后完整文案"，再输出完整文案（带 # 标题）
    marker_match = re.search(r'#\s*优化后完整文案', output, re.IGNORECASE)
    if not marker_match:
        marker_match = re.search(r'#\s*优化后.+文案', output, re.IGNORECASE)
    if not marker_match:
        marker_match = re.search(r'#\s*最终文案', output, re.IGNORECASE)
    if marker_match:
        after = output[marker_match.end():]
        # 找第一个"# 不同品种龟..."作为起点
        title_match = re.search(r'#\s*不同品种龟', after)
        if title_match:
            result = after[title_match.start():]
            result = re.sub(r'```[a-zA-Z]*\n?', '', result)
            result = re.sub(r'```', '', result)
            result = re.sub(r'^>\s?', '', result, flags=re.MULTILINE)
            result = result.strip()
            if len(result) > 200:
                return result

    # 策略 2: 直接找第一个 # 不同品种龟... 行
    title_match = re.search(r'#\s*不同品种龟[^\n]*', output)
    if title_match:
        result = output[title_match.start():]
        result = re.sub(r'```[a-zA-Z]*\n?', '', result)
        result = re.sub(r'```', '', result)
        result = re.sub(r'^>\s?', '', result, flags=re.MULTILINE)
        result = result.strip()
        if len(result) > 200:
            return result

    return None


def postprocess(text: str) -> str:
    text = re.sub(r'\*\*([^*]+)\*\*', r'\1', text)
    text = re.sub(r'^>\s?', '', text, flags=re.MULTILINE)
    text = re.sub(r'```[a-zA-Z]*\n?', '', text)
    text = re.sub(r'```', '', text)
    text = re.sub(r'\n{3,}', '\n\n', text)
    return text.strip() + '\n'


def call_with_retry(client, content, prompt, round_num, max_retry=5):
    last_error = None
    for attempt in range(max_retry):
        try:
            return client.call(content, prompt, round_num)
        except Exception as e:
            last_error = str(e)
            print(f"  尝试 {attempt+1}/{max_retry} 失败: {e}")
            time.sleep(3)
    raise Exception(f"Failed after {max_retry} attempts: {last_error}")


def main():
    config = ReviewConfig()
    client = MiniMaxClient(config)

    with open(LOG, 'r', encoding='utf-8') as f:
        rounds_log = json.load(f).get('rounds', [])

    # 第 1 轮：直接复用之前的输出，提取优化版
    r1_output = rounds_log[0]['output']
    r1_opt = extract_optimized(r1_output)
    print(f"第 1 轮提取: {len(r1_opt) if r1_opt else 0} 字符")
    if not r1_opt:
        print("第 1 轮提取失败，放弃")
        return
    current = postprocess(r1_opt)
    print(f"第 1 轮优化版 (前 300 字):\n{current[:300]}")
    rounds_log[0]['optimized_text'] = current

    # 第 2 轮：用第 1 轮结果重跑
    prompt2 = load_prompt("round2_narrative.md")
    print(f"\n========== 第 2 轮 Review (叙事) ==========")
    r2_output = call_with_retry(client, current, prompt2, 2, max_retry=5)
    r2_opt = extract_optimized(r2_output)
    if r2_opt:
        current = postprocess(r2_opt)
        print(f"第 2 轮提取到优化文案 ({len(current)} 字符)")
    else:
        print(f"第 2 轮提取失败，保留第 1 轮结果")
    rounds_log[1] = {
        "round": 2, "title": "叙事", "score": None,
        "output": r2_output, "optimized_text": current
    }

    with open(LOG, 'w', encoding='utf-8') as f:
        json.dump({"file": str(TARGET), "rounds": rounds_log, "current_text": current}, f, ensure_ascii=False, indent=2)

    # 第 3 轮：用第 2 轮结果重跑
    prompt3 = load_prompt("round3_ending.md")
    print(f"\n========== 第 3 轮 Review (结尾) ==========")
    r3_output = call_with_retry(client, current, prompt3, 3, max_retry=5)
    r3_opt = extract_optimized(r3_output)
    if r3_opt:
        # 第 3 轮通常只输出结尾段，需要合并到第 2 轮结果
        # 如果 r3_opt 包含完整文案，则直接替换
        # 如果 r3_opt 只包含结尾（无 6 站），则合并
        if '第一站' in r3_opt and '第六站' in r3_opt:
            current = postprocess(r3_opt)
            print(f"第 3 轮返回完整文案 ({len(current)} 字符)")
        else:
            # 合并：保留 current 主体（6 站），替换结尾段
            print(f"第 3 轮只返回结尾段 ({len(r3_opt)} 字符)，合并")
            # 找 current 中"好，总结时间"或"好喇，嚟个总结时间"作为结尾起点
            end_markers = [r'# 不同品种龟[^\n]*\n[\s\S]*?(?=好[，,]?\s*总结时间|好[，,]?\s*嚟个总结时间|好喇)', r'好[，,]?\s*总结时间[^\n]*\n[\s\S]*$', r'好[，,]?\s*嚟个总结时间[^\n]*\n[\s\S]*$']
            for pat in end_markers:
                m = re.search(pat, current)
                if m:
                    current = current[:m.start()] + r3_opt
                    current = postprocess(current)
                    print(f"  合并后: {len(current)} 字符")
                    break
            else:
                # 退而求其次：直接用 r3_opt
                current = postprocess(r3_opt)
    else:
        print(f"第 3 轮提取失败，保留第 2 轮结果")
    rounds_log[2] = {
        "round": 3, "title": "结尾", "score": None,
        "output": r3_output, "optimized_text": current
    }

    with open(LOG, 'w', encoding='utf-8') as f:
        json.dump({"file": str(TARGET), "rounds": rounds_log, "current_text": current}, f, ensure_ascii=False, indent=2)

    print(f"\n========== 最终文案 ({len(current)} 字符) ==========")
    print(current)


if __name__ == "__main__":
    main()
