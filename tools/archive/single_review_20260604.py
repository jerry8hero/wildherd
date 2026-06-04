#!/usr/bin/env python3
"""对单个文件做 3 轮迭代 review（直接调用 review_core）"""

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


def extract_score(output: str):
    patterns = [
        r'评分[：:]\s*[★⭐]?\s*(\d+(?:\.\d+)?)',
        r'分数[：:]\s*(\d+(?:\.\d+)?)',
        r'\*\*(\d+(?:\.\d+)?)\s*/\s*10\*\*',
        r'(\d+(?:\.\d+)?)\s*/\s*10',
    ]
    for p in patterns:
        m = re.search(p, output, re.IGNORECASE)
        if m:
            try:
                return float(m.group(1))
            except ValueError:
                pass
    return None


def extract_optimized(output: str):
    markers = [
        r'##\s*优化后的完整文案',
        r'##\s*完整优化文案',
        r'##\s*优化后完整文案',
        r'##\s*最终优化版',
        r'##\s*最终文案',
        r'##\s*优化版',
    ]
    for m in markers:
        match = re.search(m, output, re.IGNORECASE)
        if match:
            after = output[match.end():]
            after = re.sub(r'^[\s\n]*```[a-zA-Z]*', '', after)
            after = re.sub(r'^```[\s\S]*?```', '', after, count=1)
            after = re.sub(r'```', '', after)
            after = re.sub(r'^>\s?', '', after, flags=re.MULTILINE)
            after = after.strip()
            if len(after) > 200:
                return after
    return None


def postprocess(text: str) -> str:
    text = re.sub(r'\*\*([^*]+)\*\*', r'\1', text)
    text = re.sub(r'^>\s?', '', text, flags=re.MULTILINE)
    text = re.sub(r'```[a-zA-Z]*\n?', '', text)
    text = re.sub(r'```', '', text)
    text = re.sub(r'\n{3,}', '\n\n', text)
    return text.strip() + '\n'


def call_with_retry(client, content, prompt, round_num, max_retry=5):
    """带重试的 API 调用，超时后延长 timeout"""
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

    with open(TARGET, 'r', encoding='utf-8') as f:
        original = f.read()

    # 检查是否有上次的中间结果
    resume_data = None
    if LOG.exists():
        with open(LOG, 'r', encoding='utf-8') as f:
            resume_data = json.load(f)

    # 找到上次完成的轮次
    start_round = 1
    current = original
    rounds_log = []

    if resume_data and "rounds" in resume_data:
        completed_rounds = [r for r in resume_data["rounds"] if r.get("optimized_text")]
        if completed_rounds:
            last = completed_rounds[-1]
            start_round = last["round"] + 1
            current = last["optimized_text"]
            rounds_log = resume_data["rounds"]
            print(f"从第 {start_round} 轮继续，载入 {len(current)} 字符的中间结果")

    # 找到本轮标题
    prompt_files = ["round1_opening.md", "round2_narrative.md", "round3_ending.md"]
    titles = ["开场", "叙事", "结尾"]

    for i in range(start_round, 4):
        prompt = load_prompt(prompt_files[i-1])
        print(f"\n========== 第 {i} 轮 Review ({titles[i-1]}) ==========")

        try:
            output = call_with_retry(client, current, prompt, i, max_retry=5)
        except Exception as e:
            print(f"第 {i} 轮最终失败: {e}")
            break

        score = extract_score(output)
        print(f"评分: {score}")
        print(f"---前 600 字---")
        print(output[:600])
        print("...")

        optimized = extract_optimized(output)
        if optimized:
            new_text = postprocess(optimized)
            if len(new_text) > 200:
                current = new_text
                print(f"第 {i} 轮提取到优化文案 ({len(current)} 字符)")

        # 记录到 log
        log_entry = {
            "round": i,
            "score": score,
            "title": titles[i-1],
            "output": output,
            "optimized_text": current if optimized else None,
        }
        rounds_log = [r for r in rounds_log if r.get("round") != i]
        rounds_log.append(log_entry)

        with open(LOG, 'w', encoding='utf-8') as f:
            json.dump({
                "file": str(TARGET),
                "rounds": rounds_log,
                "current_text": current,
            }, f, ensure_ascii=False, indent=2)
        print(f"已保存第 {i} 轮结果到 {LOG}")

    print(f"\n========== 当前文案 (前 1500 字) ==========")
    print(current[:1500])
    print("..." if len(current) > 1500 else "")


if __name__ == "__main__":
    main()
